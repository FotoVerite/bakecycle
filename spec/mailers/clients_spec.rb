# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClientsMailer, type: :mailer do
  describe "#send_invoice" do
    let(:bakery)   { create(:bakery) }
    let(:client)   { create(:client, bakery: bakery, accounts_payable_contact_email: "ap@example.com") }
    let(:shipment) { create(:shipment, bakery: bakery, client: client) }
    let(:mail)     { ClientsMailer.send_invoice(shipment) }

    before do
      # Stub PDF generation — InvoicesPdf depends on full bakery data and is slow
      allow_any_instance_of(InvoicePdfGenerator).to receive(:generate).and_return("fake pdf content")
    end

    it "sends to the client's accounts payable email" do
      expect(mail.to).to eq(["ap@example.com"])
    end

    it "sends from the bakecycle admin address" do
      expect(mail.from).to eq(["admin@bakecycle.com"])
    end

    it "includes the invoice filename in the subject" do
      expect(mail.subject).to match(/Invoice/)
    end

    it "attaches the invoice PDF" do
      expect(mail.attachments.length).to eq(1)
      expect(mail.attachments.first.content_type).to match(%r{application/pdf})
    end

    it "names the attachment after the invoice" do
      expect(mail.attachments.first.filename).to match(/invoice.*\.pdf$/i)
    end
  end
end
