require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter do
  let(:bakery) { create(:bakery) }
  let(:connection) { instance_double(Mysql2::Client, query: []) }
  let(:importer) { LegacyImporter.new(bakery: bakery, connection: connection) }

  let(:legacy_client) do
    HashWithIndifferentAccess.new(
      'client_id' => 1,
      'client_active' => 'Y',
      'client_business_name' => 'Bien Cuit - Smith Street, LLC',
      'client_dba' => 'Bien Cuit - Smith Street',
      'client_phone' => '718-852-0200',
      'client_fax' => '718-852-0209',
      'client_delivery_address1' => '120 Smith Street',
      'client_delivery_address2' => 'Ground Floor',
      'client_delivery_city' => 'Brooklyn',
      'client_delivery_state' => 'NY',
      'client_delivery_zip' => '11201',
      'client_billing_address1' => '120 Smith Street',
      'client_billing_address2' => 'Ground Floor',
      'client_billing_city' => 'Brooklyn',
      'client_billing_state' => 'NY',
      'client_billing_zip' => '11201',
      'client_delivery_name1' => 'Aaron Long',
      'client_delivery_phone1' => '718-852-0200',
      'client_delivery_email1' => 'aaron@biencuit.com',
      'client_delivery_name2' => '',
      'client_delivery_phone2' => '',
      'client_delivery_email2' => '',
      'client_ap_name' => 'Liz Montgomery',
      'client_ap_phone' => '718-852-0200',
      'client_ap_email' => 'accounting@biencuit.com',
      'client_ap_emailcc' => 'aaron@biencuit.com',
      'client_discountpct' => BigDecimal.new('0.0'),
      'client_deliverymin' => BigDecimal.new('0.0'),
      'client_deliveryfee' => BigDecimal.new('0.0'),
      'client_deliveryfeespan' => 'daily',
      'client_deliverorpickup' => 'delivery',
      'client_deliverystart' => Time.new('2000-01-01 03:00:00 -0500'),
      'client_deliveryend' => Time.new('2000-01-01 04:00:00 -0500'),
      'client_deliveryterms' => 'Net 30',
      'client_deliverynotes' => '',
      'client_createinvoices' => 'Y',
      'client_emailinvoices' => 'N',
      'client_printinvoices' => 1,
      'client_printpackslips' => 0,
      'client_sendstatements' => 'Y',
      'client_chargedeliveryfee' => 'Y',
      'client_doc_resaleform' => '',
      'client_doc_wholesaleagreement' => '',
      'client_doc_creditcardapp' => ''
    )
  end

  describe '#import_clients' do
    it 'returns successful imports and unsuccessful imports' do
      invalid_client = legacy_client.dup.merge(client_delivery_address1: nil)
      expect(connection).to receive(:query).and_return([legacy_client, invalid_client])
      valid_clients, error_clients = importer.import_clients
      expect(error_clients.count).to eq(1)
      expect(valid_clients.count).to eq(1)
    end
  end

  describe '#import_client' do
    it 'creates a Client out of a LegacyClient' do
      client = importer.import_client(legacy_client)
      expect(client).to be_an_instance_of(Client)
      expect(client.active).to eq(true)
      expect(client).to be_valid
      expect(client).to be_persisted
    end

    it 'updates existing clients' do
      client = importer.import_client(legacy_client)
      legacy_client['client_business_name'] = 'New Name'
      updated_client = importer.import_client(legacy_client)
      expect(client).to eq(updated_client)
      client.reload
      expect(client.name).to eq('New Name')
    end
  end

  describe '#invalid_client_report' do
    it 'returns invalid clients and delivers mailer' do
      invalid_client = importer.import_client(legacy_client.merge(client_delivery_address1: nil))
      invalid_client_row = ["#{invalid_client.name}, #{invalid_client.dba}, delivery_address_street_1: \n"]
      expect(importer.invalid_client_report([invalid_client])).to eq(invalid_client_row)
      expect(ActionMailer::Base.deliveries.last.subject).to eq('Invalid clients csv')
    end
  end
end
