require "rails_helper"

describe Address do
  let(:client) { Client.new }
  let(:address) { Address.new(client, "delivery_address") }

  it "has address fields" do
    expect(address).to respond_to(:city)
    expect(address).to respond_to(:city=)
    expect(address).to respond_to(:state)
    expect(address).to respond_to(:state=)
    expect(address).to respond_to(:street_1)
    expect(address).to respond_to(:street_1=)
    expect(address).to respond_to(:street_2)
    expect(address).to respond_to(:street_2=)
    expect(address).to respond_to(:zipcode)
    expect(address).to respond_to(:zipcode=)
  end

  it "has delegates the address fields to the client" do
    expect(client).to receive(:delivery_address_street_1=)
      .with("NASA Drive")
      .and_call_original
    address.street_1 = "NASA Drive"
    expect(client).to receive(:delivery_address_street_1)
      .and_call_original
    expect(address.street_1).to eq("NASA Drive")
  end

  describe "#blank?" do
    it "returns true if all fields are blank" do
      expect(address.blank?).to eq(true)
    end
    it "returns false if all fields aren't blank" do
      client.delivery_address_state = "New Jersey"
      expect(address.blank?).to eq(false)
    end
  end

  describe "#changed?" do
    it "returns true if any field changed" do
      expect(address.changed?).to eq(false)
      client.delivery_address_state = "New Jersey"
      expect(address.changed?).to eq(true)
    end
  end

  describe "#full" do
    let(:client) { build(:client) }
    it "returns all available address data" do
      address.street_2 = "floor 5"
      full_address = "#{address.street_1}\n#{address.street_2}\n#{address.city}, #{address.state} #{address.zipcode}"
      expect(address.full).to eq(full_address)
    end

    it "doesn't leave hanging commas or new lines" do
      address.city = nil
      address.state = nil
      address.street_1 = nil
      full_address = "#{address.zipcode}"
      expect(address.full).to eq(full_address)
    end
  end
end
