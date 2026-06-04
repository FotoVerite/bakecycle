require "rails_helper"

describe FileExportSerializer do
  let(:bakery) { create(:bakery) }
  let(:file_export) { create(:file_export, bakery: bakery) }

  subject(:hash) { FileExportSerializer.new(file_export).serializable_hash }

  it "includes core attributes" do
    expect(hash).to include(:id, :created_at, :updated_at)
  end

  it "includes a links hash with self and file keys" do
    expect(hash[:links]).to include(:self, :file)
  end

  it "includes ready? as an attribute" do
    expect(hash).to have_key(:"ready?")
  end

  it "includes loading_message" do
    expect(hash).to have_key(:loading_message)
  end

  # FileExportDecorator#serializable_hash applies camelCase transform
  describe "via FileExportDecorator#serializable_hash" do
    let(:decorator) { FileExportDecorator.new(file_export) }

    it "serializes without error" do
      expect { decorator.serializable_hash }.not_to raise_error
    end

    it "provides a loading message for the pending export page" do
      expect(decorator.loading_message).to be_present
    end

    it "returns camelCase string keys" do
      result = decorator.serializable_hash
      expect(result).to have_key("id")
      expect(result).to have_key("createdAt")
      expect(result).to have_key("updatedAt")
      expect(result).to have_key("loadingMessage")
      expect(result).to have_key("links")
    end
  end
end
