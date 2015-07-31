require "rails_helper"

describe Client do
  let(:client) { build(:client) }
  let(:client_with_fee) { build(:client, :with_delivery_fee) }

  it "has a shape" do
    expect(client).to respond_to(:name)
    expect(client).to respond_to(:notes)
    expect(client).to respond_to(:official_company_name)
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
    expect(client).to respond_to(:delivery_fee_option)
    expect(client).to respond_to(:delivery_minimum)
    expect(client).to respond_to(:delivery_fee)

    expect(client).to belong_to(:bakery)
  end

  it "has validations" do
    expect(client).to validate_presence_of(:name)
    expect(client).to validate_length_of(:name).is_at_most(150)
    expect(client).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
    expect(client).to validate_presence_of(:delivery_fee_option)
    expect(client).to validate_presence_of(:delivery_minimum)
    expect(client).to validate_numericality_of(:delivery_minimum)
    expect(client).to validate_presence_of(:delivery_fee)
    expect(client).to validate_numericality_of(:delivery_fee)
  end

  it "can have same name if are apart of different bakeries" do
    biencuit = create(:bakery)
    client_name = "Grumpy Cafe"
    create(:client, name: client_name, bakery: biencuit)
    expect(create(:client, name: client_name)).to be_valid
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
    client_with_fee.delivery_fee = nil
    expect(client_with_fee).to_not be_valid
  end

  it "delivery minimum should never be nil" do
    client_with_fee.delivery_minimum = nil
    expect(client_with_fee).to_not be_valid
  end

  it "delivery fee validations" do
    expect(build(:client, :with_delivery_fee, delivery_minimum: "not a number")).to_not be_valid
    expect(build(:client, :with_delivery_fee, delivery_fee: "not a number")).to_not be_valid
  end

  describe "geocoding" do
    it "geocodes new records" do
      client = build(:client, latitude: nil, longitude: nil)
      expect(client).to receive(:latitude=).and_call_original
      expect(client).to receive(:longitude=).and_call_original
      client.valid?
      expect(client.latitude).to_not be_nil
      expect(client.longitude).to_not be_nil
    end

    it "create doesn't geocode if the lat/long is supplied already" do
      client = build(:client)
      expect(client).to_not receive(:latitude=)
      expect(client).to_not receive(:longitude=)
      client.valid?
      expect(client.latitude).to_not be_nil
      expect(client.longitude).to_not be_nil
    end

    it "geocodes address changes" do
      client = create(:client)
      expect(client).to receive(:latitude=)
      expect(client).to receive(:longitude=)
      client.delivery_address_street_2 = "Apt. 4"
      client.valid?
    end

    it "doesn't geocode if the address doesn't chanage" do
      client = create(:client)
      expect(client).to_not receive(:latitude=)
      expect(client).to_not receive(:longitude=)
      client.valid?
    end
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
