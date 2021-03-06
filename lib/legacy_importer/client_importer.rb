module LegacyImporter
  class ClientImporter
    attr_reader :data, :bakery

    def initialize(bakery, legacy_clients)
      @bakery = bakery
      @data = legacy_clients
      @field_mapper = FieldMapper.new(FIELDS_MAP)
    end

    FIELDS_MAP = %w[
      client_active active
      client_business_name official_company_name
      client_dba name

      client_billing_address1 billing_address_street_1
      client_billing_address2 billing_address_street_2
      client_billing_city billing_address_city
      client_billing_state billing_address_state
      client_billing_zip billing_address_zipcode

      client_delivery_address1 delivery_address_street_1
      client_delivery_address2 delivery_address_street_2
      client_delivery_city delivery_address_city
      client_delivery_state delivery_address_state
      client_delivery_zip delivery_address_zipcode

      client_ap_email accounts_payable_contact_email
      client_ap_name accounts_payable_contact_name
      client_ap_phone accounts_payable_contact_phone

      client_delivery_name1 primary_contact_name
      client_delivery_email1 primary_contact_email
      client_delivery_phone1 primary_contact_phone

      client_delivery_name2 secondary_contact_name
      client_delivery_email2 secondary_contact_email
      client_delivery_phone2 secondary_contact_phone

      client_deliveryfee delivery_fee
      client_deliverymin delivery_minimum
      client_deliveryterms billing_term
      client_deliverynotes notes
      client_fax business_fax
      client_phone business_phone
    ].freeze

    # Fields we have yet to import
    # client_ap_emailcc
    # client_createinvoices
    # client_deliverorpickup
    # client_deliveryend
    # client_deliverystart
    # client_discountpct
    # client_doc_creditcardapp
    # client_doc_resaleform
    # client_doc_wholesaleagreement
    # client_printinvoices
    # client_printpackslips
    # client_sendstatements

    BILLING_TERMS_MAP = {
      "Net 30" => :net_30,
      "Credit Card" => :credit_card,
      "COD" => :cod,
      "Net 15" => :net_15,
      "" => :net_30
    }.freeze

    def import!
      return SkippedClient.new(attributes) if skip?
      ObjectFinder.new(
        Client,
        bakery: bakery,
        legacy_id: data[:client_id].to_s
      ).update(attributes)
    end

    class SkippedClient < SkippedObject
    end

    private

    def skip?
      no_name?
    end

    def no_name?
      data[:client_business_name].blank? && data[:client_dba].blank?
    end

    def not_active?
      data[:client_active] != "Y"
    end

    def sample?
      data[:client_business_name].include?("Samples") ||
        data[:client_dba].include?("Samples")
    end

    def catering?
      data[:client_business_name].include?("Catering") ||
        data[:client_dba].include?("Catering")
    end

    def attributes
      client_attr = @field_mapper.translate(data)
      client_attr.merge(
        billing_term: BILLING_TERMS_MAP[client_attr[:billing_term]],
        active: active?,
        name: client_attr[:name] || client_attr[:official_company_name],
        delivery_fee_option: delivery_fee,
        accounts_payable_contact_name: client_attr[:accounts_payable_contact_name] || data[:primary_contact_name]
      )
    end

    def active?
      data[:client_active] == "Y"
    end

    def delivery_fee
      "#{data[:client_deliveryfeespan]}_delivery_fee".to_sym
    end
  end
end
