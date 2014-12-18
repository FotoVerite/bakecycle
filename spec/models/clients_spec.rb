require "rails_helper"

describe Client do
  let(:client) { build(:client) }

  describe "model attributes" do
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
  describe "validations" do

    describe "name" do
      it { expect(client).to validate_presence_of(:name) }
      it { expect(client).to ensure_length_of(:name).is_at_most(150) }
      it { expect(client).to validate_uniqueness_of(:name) }
    end

    describe "dba" do
      it { expect(client).to ensure_length_of(:dba).is_at_most(150) }
    end

    describe "business_phone" do
      it { expect(client).to validate_presence_of(:business_phone) }
    end

    describe "delivery_address_street_1" do
      it { expect(client).to validate_presence_of(:delivery_address_street_1) }
    end

    describe "delivery_address_city" do
      it { expect(client).to validate_presence_of(:delivery_address_city) }
    end

    describe "delivery_address_state" do
      it { expect(client).to validate_presence_of(:delivery_address_state) }
    end

    describe "delivery_address_zipcode" do
      it { expect(client).to validate_presence_of(:delivery_address_zipcode) }
    end

    describe "billing_address_street_1" do
      it { expect(client).to validate_presence_of(:billing_address_street_1) }
    end

    describe "billing_address_city" do
      it { expect(client).to validate_presence_of(:billing_address_city) }
    end

    describe "billing_address_state" do
      it { expect(client).to validate_presence_of(:billing_address_state) }
    end

    describe "billing_address_zipcode" do
      it { expect(client).to validate_presence_of(:billing_address_zipcode) }
    end

    describe "accounts_payable_contact_name" do
      it { expect(client).to validate_presence_of(:accounts_payable_contact_name) }
      it { expect(client).to ensure_length_of(:accounts_payable_contact_name).is_at_most(150) }
    end

    describe "accounts_payable_contact_phone" do
      it { expect(client).to validate_presence_of(:accounts_payable_contact_phone) }
    end

    describe "accounts_payable_contact_email" do
      it { expect(client).to validate_presence_of(:accounts_payable_contact_email) }
      it "is contains an @ symbol" do
        expect(build(:client, accounts_payable_contact_email: "not an email")).to_not be_valid
        expect(build(:client, accounts_payable_contact_email: "user@example.com")).to be_valid
      end
    end

    describe "primary_contact_name" do
      it { expect(client).to validate_presence_of(:primary_contact_name) }
      it { expect(client).to ensure_length_of(:primary_contact_name).is_at_most(150) }
    end

    describe "primary_contact_phone" do
      it { expect(client).to validate_presence_of(:primary_contact_phone) }
    end

    describe "primary_contact_email" do
      it { expect(client).to validate_presence_of(:primary_contact_email) }
      it "is contains an @ symbol" do
        expect(build(:client, primary_contact_email: "not an email")).to_not be_valid
        expect(build(:client, primary_contact_email: "user@example.com")).to be_valid
      end
    end
  end
end
