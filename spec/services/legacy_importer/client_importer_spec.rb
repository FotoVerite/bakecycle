require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter::ClientImporter do
  let(:bakery) { create(:bakery) }
  let(:importer) { LegacyImporter::ClientImporter.new(bakery, legacy_client) }

  let(:legacy_client) do
    {
      client_id: 1,
      client_active: 'Y',
      client_business_name: 'Bien Cuit - Smith Street, LLC',
      client_dba: 'Bien Cuit - Smith Street',
      client_phone: '718-852-0200',
      client_fax: '718-852-0209',
      client_delivery_address1: '120 Smith Street',
      client_delivery_address2: 'Ground Floor',
      client_delivery_city: 'Brooklyn',
      client_delivery_state: 'NY',
      client_delivery_zip: '11201',
      client_billing_address1: '120 Smith Street',
      client_billing_address2: 'Ground Floor',
      client_billing_city: 'Brooklyn',
      client_billing_state: 'NY',
      client_billing_zip: '11201',
      client_delivery_name1: 'Aaron Long',
      client_delivery_phone1: '718-852-0200',
      client_delivery_email1: 'aaron@biencuit.com',
      client_delivery_name2: '',
      client_delivery_phone2: '',
      client_delivery_email2: '',
      client_ap_name: 'Liz Montgomery',
      client_ap_phone: '718-852-0200',
      client_ap_email: 'accounting@biencuit.com',
      client_ap_emailcc: 'aaron@biencuit.com',
      client_discountpct: BigDecimal.new('0.0'),
      client_deliverymin: BigDecimal.new('0.0'),
      client_deliveryfee: BigDecimal.new('0.0'),
      client_deliveryfeespan: 'daily',
      client_deliverorpickup: 'delivery',
      client_deliverystart: Time.zone.local('2000-01-01 03:00:00 -0500'),
      client_deliveryend: Time.zone.local('2000-01-01 04:00:00 -0500'),
      client_deliveryterms: 'Net 30',
      client_deliverynotes: '',
      client_createinvoices: 'Y',
      client_emailinvoices: 'N',
      client_printinvoices: 1,
      client_printpackslips: 0,
      client_sendstatements: 'Y',
      client_chargedeliveryfee: 'Y',
      client_doc_resaleform: '',
      client_doc_wholesaleagreement: '',
      client_doc_creditcardapp: ''
    }
  end

  describe '#import!' do
    it 'creates a Client out of a LegacyClient' do
      (client, _), _ = importer.import!
      expect(client).to be_an_instance_of(Client)
      expect(client.active).to eq(true)
      expect(client).to be_valid
      expect(client).to be_persisted
    end

    it 'returns unsuccessful import' do
      legacy_client[:client_deliverymin] = 'a'
      client = importer.import!
      expect(client).to_not be_valid
      expect(client).to_not be_persisted
    end

    it 'updates existing clients' do
      client = importer.import!
      legacy_client[:client_business_name] = 'New Name'
      updated_client = importer.import!

      expect(updated_client.name).to eq('New Name')
      expect(client).to eq(updated_client)
      client.reload
      expect(client.name).to eq('New Name')
    end

    it 'skips clients who have no name' do
      legacy_client[:client_business_name] = nil
      legacy_client[:client_dba] = nil
      skipped_client = importer.import!
      expect(skipped_client).to be_valid
      expect(skipped_client).to_not be_persisted
    end
  end
end
