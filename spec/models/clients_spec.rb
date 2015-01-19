require "rails_helper"

describe Client do
  let(:client) { build(:client) }

  context "model attributes" do
    it { expect(client).to respond_to(:name) }
    it { expect(client).to respond_to(:dba) }
    it { expect(client).to respond_to(:business_phone) }
    it { expect(client).to respond_to(:business_fax) }
    it { expect(client).to respond_to(:active) }
    it { expect(client).to respond_to(:delivery_address_street_1) }
    it { expect(client).to respond_to(:delivery_address_street_2) }
    it { expect(client).to respond_to(:delivery_address_city) }
    it { expect(client).to respond_to(:delivery_address_state) }
    it { expect(client).to respond_to(:delivery_address_zipcode) }
    it { expect(client).to respond_to(:billing_address_street_1) }
    it { expect(client).to respond_to(:billing_address_street_2) }
    it { expect(client).to respond_to(:billing_address_city) }
    it { expect(client).to respond_to(:billing_address_state) }
    it { expect(client).to respond_to(:billing_address_zipcode) }
    it { expect(client).to respond_to(:accounts_payable_contact_name) }
    it { expect(client).to respond_to(:accounts_payable_contact_phone) }
    it { expect(client).to respond_to(:accounts_payable_contact_email) }
    it { expect(client).to respond_to(:primary_contact_name) }
    it { expect(client).to respond_to(:primary_contact_phone) }
    it { expect(client).to respond_to(:primary_contact_email) }
    it { expect(client).to respond_to(:secondary_contact_name) }
    it { expect(client).to respond_to(:secondary_contact_phone) }
    it { expect(client).to respond_to(:secondary_contact_email) }
  end

  context "validations" do
    it { expect(client).to validate_presence_of(:name) }
    it { expect(client).to ensure_length_of(:name).is_at_most(150) }
    it { expect(client).to validate_uniqueness_of(:name) }
    it { expect(client).to ensure_length_of(:dba).is_at_most(150) }
    it { expect(client).to validate_presence_of(:business_phone) }

    it { expect(client).to validate_presence_of(:delivery_address_street_1) }
    it { expect(client).to validate_presence_of(:delivery_address_city) }
    it { expect(client).to validate_presence_of(:delivery_address_state) }
    it { expect(client).to validate_presence_of(:delivery_address_zipcode) }

    it { expect(client).to validate_presence_of(:billing_address_street_1) }
    it { expect(client).to validate_presence_of(:billing_address_city) }
    it { expect(client).to validate_presence_of(:billing_address_state) }
    it { expect(client).to validate_presence_of(:billing_address_zipcode) }

    it { expect(client).to validate_presence_of(:accounts_payable_contact_name) }
    it { expect(client).to ensure_length_of(:accounts_payable_contact_name).is_at_most(150) }

    it { expect(client).to validate_presence_of(:accounts_payable_contact_phone) }
    it { expect(client).to validate_presence_of(:accounts_payable_contact_email) }

    it "requires accounts_payable_contact_email to have an @ symbol" do
      expect(build(:client, accounts_payable_contact_email: "not an email")).to_not be_valid
      expect(build(:client, accounts_payable_contact_email: "user@example.com")).to be_valid
    end

    it { expect(client).to validate_presence_of(:primary_contact_name) }
    it { expect(client).to ensure_length_of(:primary_contact_name).is_at_most(150) }
    it { expect(client).to validate_presence_of(:primary_contact_phone) }
    it { expect(client).to validate_presence_of(:primary_contact_email) }

    it "requires primary_contact_email to have an @ symbol" do
      expect(build(:client, primary_contact_email: "not an email")).to_not be_valid
      expect(build(:client, primary_contact_email: "user@example.com")).to be_valid
    end

    it "requires active" do
      client.active = nil
      expect(client).to_not be_valid
    end
  end
end
