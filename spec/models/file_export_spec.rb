# frozen_string_literal: true

# == Schema Information
#
# Table name: file_exports
#
#  id                :uuid             not null, primary key
#  bakery_id         :integer          not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_fingerprint  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require "rails_helper"

describe FileExport do
  let(:file_export) { build_stubbed(:file_export) }

  it "has a shape" do
    expect(file_export).to respond_to(:bakery)
    expect(file_export).to respond_to(:file)
  end

  describe "#download_url" do
    it "returns nil until a file is attached" do
      allow(file_export).to receive(:ready?).and_return(false)

      expect(file_export.download_url).to be_nil
    end

    it "uses an expiring attachment URL" do
      attachment = instance_double(Paperclip::Attachment, expiring_url: "https://signed.example.test/export")
      allow(file_export).to receive(:ready?).and_return(true)
      allow(file_export).to receive(:file).and_return(attachment)

      expect(file_export.download_url).to eq("https://signed.example.test/export")
      expect(attachment).to have_received(:expiring_url).with(10.minutes.to_i)
    end
  end
end
