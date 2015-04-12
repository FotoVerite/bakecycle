require 'mysql2'
require 'uri'
require 'csv'

class LegacyClientImporter
  attr_reader :connection, :bakery

  def initialize(bakery:, connection:)
    @bakery = bakery
    @connection = connection
  end

  def import!
    clients.map { |client|
      Importer.new(client, bakery).import!
    }.compact.partition(&:valid?)
  end

  def clients
    connection.query('SELECT * FROM bc_clients', symbolize_keys: true, stream: true)
  end

  class Report
    attr_reader :objects

    def initialize(objects)
      @objects = objects
    end

    def invalid_objects
      objects.sort_by(&:name).map do |client|
        invalid_keys = client.errors.messages.keys
        invalid_attributes = invalid_keys.map { |key| "#{key}:#{client[key].inspect}" }.join(' ')
        [client.name, client.dba, invalid_attributes]
      end
    end

    def csv
      CSV.generate(headers: true) do |csv|
        csv << ['Name', 'DBA', 'Invalid Attributes']
        invalid_objects.each { |row| csv << row }
      end
    end

    def send_email
      LegacyImporterMailer.invalid_clients_csv(csv).deliver_now
    end
  end

  class Importer
    FIELDS_MAP = %w(
      client_active             active
      client_business_name      name
      client_dba                dba

      client_billing_address1   billing_address_street_1
      client_billing_address2   billing_address_street_2
      client_billing_city       billing_address_city
      client_billing_state      billing_address_state
      client_billing_zip        billing_address_zipcode

      client_delivery_address1  delivery_address_street_1
      client_delivery_address2  delivery_address_street_2
      client_delivery_city      delivery_address_city
      client_delivery_state     delivery_address_state
      client_delivery_zip       delivery_address_zipcode

      client_ap_email           accounts_payable_contact_email
      client_ap_name            accounts_payable_contact_name
      client_ap_phone           accounts_payable_contact_phone

      client_delivery_name1     primary_contact_name
      client_delivery_email1    primary_contact_email
      client_delivery_phone1    primary_contact_phone

      client_delivery_name2     secondary_contact_name
      client_delivery_email2    secondary_contact_email
      client_delivery_phone2    secondary_contact_phone

      client_deliveryfee        delivery_fee
      client_deliverymin        delivery_minimum
      client_deliveryterms      billing_term
      client_fax                business_fax
      client_phone              business_phone
    ).map(&:to_sym).each_slice(2)

    # client_ap_emailcc
    # client_createinvoices
    # client_deliverorpickup
    # client_deliveryend
    # client_deliverynotes
    # client_deliverystart
    # client_discountpct
    # client_doc_creditcardapp
    # client_doc_resaleform
    # client_doc_wholesaleagreement
    # client_printinvoices
    # client_printpackslips
    # client_sendstatements

    BILLING_TERMS_MAP = {
      'Net 30' => :net_30,
      'Credit Card' => :credit_card,
      'COD' => :cod,
      'Net 15' => :net_15,
      '' => :net_30
    }

    attr_reader :data, :bakery

    def initialize(legacy_client, bakery)
      @data = legacy_client
      @bakery = bakery
    end

    def import!
      return if skip?
      Client.where(
        bakery: bakery,
        legacy_id: data[:client_id].to_s
      )
        .first_or_initialize
        .tap { |c| c.update(attributes) }
    end

    def skip?
      no_name? || not_active?
    end

    def no_name?
      data[:client_business_name].blank? && data[:client_dba].blank?
    end

    def not_active?
      data[:client_business_name].include?('Samples') || data[:client_active] != 'Y'
    end

    def attributes
      client_attr = map_attrs
      client_attr.merge(
        billing_term: BILLING_TERMS_MAP[client_attr[:billing_term]],
        active: active?,
        name: client_attr[:name] || data[:client_dba],
        delivery_fee_option: delivery_fee,
        accounts_payable_contact_name: client_attr[:accounts_payable_contact_name] ||= data[:primary_contact_name]
      )
    end

    def map_attrs
      FIELDS_MAP.each_with_object({}) do |(legacy_field, field), client_hash|
        client_hash[field] = data[legacy_field] unless data[legacy_field] == ''
      end
    end

    def active?
      data[:client_active] == 'Y'
    end

    def delivery_fee
      "#{data[:client_deliveryfeespan]}_delivery_fee".to_sym
    end
  end
end
