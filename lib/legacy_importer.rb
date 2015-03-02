require 'mysql2'
require 'uri'

class LegacyImporter
  attr_reader :connection, :bakery

  def initialize(bakery:, connection_url: ENV['LEGACY_BAKECYCLE_DATABASE_URL'], connection: nil)
    @bakery = bakery
    @connection = connection || connect(connection_url)
  end

  def connect(connection_url)
    info = URI.parse(connection_url)
    database = info.path.gsub(/^\//, '')
    Mysql2::Client.new(
      host: info.host,
      username: info.user,
      password: info.password,
      database: database,
      reconnect: true
    )
  end

  def clients
    connection.query('SELECT * FROM bc_clients', symbolize_keys: true, stream: true)
  end

  USER_FIELDS_MAP = %w(
    client_active             active
    client_business_name      name
    client_chargedeliveryfee  charge_delivery_fee
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
  # client_deliveryfeespan
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

  def import_clients
    clients.reject { |client| skip_client?(client) }.map { |client| import_client(client) }.partition(&:valid?)
  end

  def import_client(legacy_client)
    client_attr = translate_fields(legacy_client)

    client_attr[:billing_term] = BILLING_TERMS_MAP[client_attr[:billing_term]]
    client_attr[:active] = client_attr[:active] == 'Y'
    client_attr[:name] ||= client_attr[:dba]

    client_attr[:business_phone] ||= 'unknown'

    client_attr[:primary_contact_name] ||= 'unknown'
    client_attr[:primary_contact_phone] ||= 'unknown'
    client_attr[:primary_contact_email] ||= 'unknown@example.com'

    client_attr[:accounts_payable_contact_name] ||= client_attr[:primary_contact_name]
    client_attr[:accounts_payable_contact_phone] ||= client_attr[:primary_contact_phone]
    client_attr[:accounts_payable_contact_email] ||= client_attr[:primary_contact_email]

    client_id = { bakery: bakery, legacy_id: legacy_client[:client_id].to_s }
    client = Client.where(client_id).first_or_create
    client.update(client_attr)
    client
  end

  private

  def skip_client?(client)
    if client[:name].blank? && client[:dba].blank?
      Rails.logger.info "Skipping Legacy ID #{client[:client_id]} due to blank name and dba"
      return true
    end
    false
  end

  def translate_fields(legacy_client)
    USER_FIELDS_MAP.each_with_object({}) do |(legacy_field, field), client_attr|
      client_attr[field] = legacy_client[legacy_field] unless client_attr[field] == ''
    end
  end
end
