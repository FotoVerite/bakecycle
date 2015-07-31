require "rails_helper"

describe BaseSearchForm do
  class MySearchForm < BaseSearchForm
    search_for_many :client_id, :product_id
    search_for_date :date_from, :date_to
  end

  describe ".params" do
    it "has params for each declared field" do
      expect(MySearchForm.params).to eq([{ client_id: [] }, { product_id: [] }, :date_from, :date_to])
    end
  end

  it "accepts nil" do
    expect(MySearchForm.new(nil)).to be_a(MySearchForm)
  end

  it "parses date fields" do
    search_form = MySearchForm.new(date_to: "30/12/2015")
    search_form.date_from = "1/1/2015"
    expect(search_form.date_to).to eq(Date.parse("30/12/2015"))
    expect(search_form.date_from).to eq(Date.parse("1/1/2015"))
  end

  it "rejects invalid dates" do
    expect(MySearchForm.new(date_to: "jim").date_to).to be_nil
  end

  it "takes one or more ids for a many search" do
    search_form = MySearchForm.new(client_id: 1, product_id: [2, 3])
    expect(search_form.client_id).to eq([1])
    expect(search_form.product_id).to eq([2, 3])
  end

  it "returns fields in a hash" do
    search_form = MySearchForm.new(client_id: 1, date_to: "foo")
    expect(search_form.to_h).to include(client_id: [1], date_to: nil, date_from: nil, product_id: [])
  end

  it "has keys like a hash" do
    form = MySearchForm.new(client_id: 1, date_to: "foo")
    expect(form[:client_id]).to eq([1])
    expect(form[:date_to]).to be_nil
  end
end
