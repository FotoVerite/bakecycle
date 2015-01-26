require "rails_helper"

describe ShipmentSearchForm do
  it "accepts nil" do
    expect(ShipmentSearchForm.new(nil)).to be_a(ShipmentSearchForm)
  end

  it "parses dates" do
    search_form = ShipmentSearchForm.new(date_to: "30/12/2015", date_from: "1/1/2015")
    expect(search_form.date_to).to eq(Date.parse("30/12/2015"))
    expect(search_form.date_from).to eq(Date.parse("1/1/2015"))
  end

  it "returns valid fields in a hash" do
    form_hash = ShipmentSearchForm.new(client_id: 1, date_to: "foo").to_h
    expect(form_hash).to eq(client_id: 1, date_to: nil, date_from: nil)
  end
end
