require "rails_helper"

describe Client do
  let(:client) { build(:client) }

  it "has model attributes" do
    expect(client).to respond_to(:name)
    expect(client).to respond_to(:dba)
    expect(client).to respond_to(:business_phone)
    expect(client).to respond_to(:business_fax)
    expect(client).to respond_to(:active)
    expect(client).to respond_to(:delivery_address_street_1)
    expect(client).to respond_to(:delivery_address_street_2)
    expect(client).to respond_to(:delivery_address_city)
    expect(client).to respond_to(:delivery_address_state)
    expect(client).to respond_to(:delivery_address_zipcode)
    expect(client).to respond_to(:billing_address_street_1)
    expect(client).to respond_to(:billing_address_street_2)
    expect(client).to respond_to(:billing_address_city)
    expect(client).to respond_to(:billing_address_state)
    expect(client).to respond_to(:billing_address_zipcode)
    expect(client).to respond_to(:accounts_payable_contact_name)
    expect(client).to respond_to(:accounts_payable_contact_phone)
    expect(client).to respond_to(:accounts_payable_contact_email)
    expect(client).to respond_to(:primary_contact_name)
    expect(client).to respond_to(:primary_contact_phone)
    expect(client).to respond_to(:primary_contact_email)
    expect(client).to respond_to(:secondary_contact_name)
    expect(client).to respond_to(:secondary_contact_phone)
    expect(client).to respond_to(:secondary_contact_email)
    expect(client).to respond_to(:charge_delivery_fee)
    expect(client).to respond_to(:delivery_minimum)
    expect(client).to respond_to(:delivery_fee)
  end

  it "has association" do
    expect(client).to belong_to(:bakery)
  end

  it "has validations" do
    expect(client).to validate_presence_of(:name)
    expect(client).to ensure_length_of(:name).is_at_most(150)
    expect(client).to validate_uniqueness_of(:name)
    expect(client).to ensure_length_of(:dba).is_at_most(150)
    expect(client).to validate_presence_of(:business_phone)
    expect(client).to validate_presence_of(:delivery_address_street_1)
    expect(client).to validate_presence_of(:delivery_address_city)
    expect(client).to validate_presence_of(:delivery_address_state)
    expect(client).to validate_presence_of(:delivery_address_zipcode)
    expect(client).to validate_presence_of(:billing_address_street_1)
    expect(client).to validate_presence_of(:billing_address_city)
    expect(client).to validate_presence_of(:billing_address_state)
    expect(client).to validate_presence_of(:billing_address_zipcode)
    expect(client).to validate_presence_of(:accounts_payable_contact_name)
    expect(client).to ensure_length_of(:accounts_payable_contact_name).is_at_most(150)
    expect(client).to validate_presence_of(:accounts_payable_contact_phone)
    expect(client).to validate_presence_of(:accounts_payable_contact_email)
    expect(client).to validate_presence_of(:primary_contact_name)
    expect(client).to ensure_length_of(:primary_contact_name).is_at_most(150)
    expect(client).to validate_presence_of(:primary_contact_phone)
    expect(client).to validate_presence_of(:primary_contact_email)
    expect(client).to validate_presence_of(:delivery_minimum)
    expect(client).to validate_numericality_of(:delivery_minimum)
    expect(client).to validate_presence_of(:delivery_fee)
    expect(client).to validate_numericality_of(:delivery_fee)
  end

  it "requires accounts_payable_contact_email to have an @ symbol" do
    expect(build(:client, accounts_payable_contact_email: "not an email")).to_not be_valid
    expect(build(:client, accounts_payable_contact_email: "user@example.com")).to be_valid
  end

  it "requires primary_contact_email to have an @ symbol" do
    expect(build(:client, primary_contact_email: "not an email")).to_not be_valid
    expect(build(:client, primary_contact_email: "user@example.com")).to be_valid
  end

  it "client active should never be nil" do
    client.active = nil
    expect(client).to_not be_valid
  end

  it "delivery fee should never be nil" do
    client.delivery_fee = nil
    expect(client).to_not be_valid
  end

  it "delivery minimum should never be nil" do
    client.delivery_minimum = nil
    expect(client).to_not be_valid
  end

  it "is not a number" do
    expect(build(:client, delivery_minimum: "not a number")).to_not be_valid
    expect(build(:client, delivery_fee: "not a number")).to_not be_valid
  end

  describe ".billing_term_days" do
    it "reads billing_term from client and returns an integer" do
      client = build(:client, billing_term: :net_30)
      expect(client.billing_term_days).to eq(30)

      client.billing_term = "cod"
      expect(client.billing_term_days).to eq(0)

      client.billing_term = :credit_card
      expect(client.billing_term_days).to eq(0)

      client.billing_term = "net_7"
      expect(client.billing_term_days).to eq(7)
    end
  end
end
