require "rails_helper"
require "legacy_importer"

describe LegacyImporter::Reporter do
  let(:invalid_client) { build(:client, name: nil, legacy_id: 4).tap(&:valid?) }
  let(:client) { build_stubbed(:client) }
  let(:skipped_client) { LegacyImporter::ClientImporter::SkippedClient.new(attributes_for(:client)) }
  let(:reporter) { LegacyImporter::Reporter.new([client, invalid_client, skipped_client]) }

  describe "#invalid_client_report" do
    it "returns invalid clients" do
      csv = reporter.csv
      expect(csv).to include(invalid_client.legacy_id)
      expect(csv).to include("Name can't be blank")
    end

    it "delivers invalid client csv mailer" do
      reporter.send_email
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Invalid clients csv")
      expect(ActionMailer::Base.deliveries.last.attachments.first.content_type). to eq("text/csv; charset=UTF-8")
    end
  end

  describe "stats" do
    it "knows how many things happened" do
      expect(reporter.imported_count).to eq(1)
      expect(reporter.skipped_count).to eq(1)
      expect(reporter.invalid_count).to eq(1)
    end
  end

  describe "#skipped_report" do
    it "says how many skipped of each type of thing" do
      expect(reporter.skipped_report).to eq "Skipped 1 LegacyImporter::ClientImporter::SkippedClient"
    end
  end
end
