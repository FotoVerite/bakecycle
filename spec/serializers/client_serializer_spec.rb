require "rails_helper"

describe ClientSerializer do
  let(:client) { create(:client) }

  subject(:hash) { ClientSerializer.new(client).serializable_hash }

  it "includes expected attributes as symbol keys" do
    expect(hash).to include(:id, :name, :active, :links)
  end

  it "includes a links hash with view, edit, and newOrder urls" do
    expect(hash[:links]).to include(:view, :edit, :newOrder)
  end

  it "includes latitude and longitude" do
    expect(hash).to have_key(:latitude)
    expect(hash).to have_key(:longitude)
  end

  # ClientDecorator#serializable_hash applies camelCase transform on top
  describe "via ClientDecorator#serializable_hash" do
    let(:decorator) { ClientDecorator.new(client) }

    it "serializes without error" do
      expect { decorator.serializable_hash }.not_to raise_error
    end

    it "returns camelCase string keys" do
      result = decorator.serializable_hash
      expect(result).to have_key("id")
      expect(result).to have_key("name")
      expect(result).to have_key("links")
    end

    it "camelCases multi-word attribute keys" do
      result = decorator.serializable_hash
      expect(result).to have_key("officialCompanyName")
      expect(result).to have_key("deliveryAddressFull")
      expect(result).to have_key("engagementStatus")
      expect(result).to have_key("apiKey")
    end
  end
end
