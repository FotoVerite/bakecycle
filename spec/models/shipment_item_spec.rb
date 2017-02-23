# == Schema Information
#
# Table name: shipment_items
#
#  id                      :integer          not null, primary key
#  shipment_id             :integer
#  product_id              :integer
#  product_name            :string
#  product_quantity        :integer          default(0), not null
#  product_price           :decimal(, )      default(0.0), not null
#  product_sku             :string
#  production_start        :date             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  production_run_id       :integer
#  product_product_type    :string           not null
#  product_total_lead_days :integer          not null
#

require "rails_helper"

describe ShipmentItem do
  let(:shipment_item) { build(:shipment_item) }

  it "has model attributes" do
    expect(shipment_item).to respond_to(:shipment)
    expect(shipment_item).to respond_to(:product_id)
    expect(shipment_item).to respond_to(:product_name)
    expect(shipment_item).to respond_to(:product_quantity)
    expect(shipment_item).to respond_to(:product_price)
    expect(shipment_item).to respond_to(:product_sku)
  end

  it "has association" do
    expect(shipment_item).to belong_to(:shipment)
  end

  it "has validations" do
    expect(shipment_item).to validate_presence_of(:product_id)
    expect(shipment_item).to validate_presence_of(:product_name)
    expect(shipment_item).to validate_numericality_of(:product_quantity)
    expect(shipment_item).to validate_numericality_of(:product_price)
  end

  describe "#price" do
    it "returns the price" do
      shipment_item = build(:shipment_item, product_price: 10, product_quantity: 10)
      expect(shipment_item.price).to eq(100)
    end
  end

  describe "#product=" do
    it "sets product data on shipment item" do
      product = build_stubbed(:product, :with_sku)
      shipment_item = ShipmentItem.new
      shipment_item.product = product

      fields = [
        :id,
        :name,
        :sku,
        :product_type,
        :total_lead_days
      ]

      fields.each do |field|
        expect(shipment_item.send("product_#{field}".to_sym)).to eq(product.send(field))
      end
    end

    it "sets product_name from the name of the related product if that product exists" do
      product = create(:product, name: "Product1")
      shipment_item = create(:shipment_item, product: product)
      expect(shipment_item.product_name).to eq("Product1")
    end

    it "sets product_sku from the name of the related product if that product exists" do
      product = create(:product, :with_sku)
      shipment_item = create(:shipment_item, product: product)
      expect(shipment_item.product_sku).to eq(product.sku)
    end
  end

  describe "#production_start" do
    it "sets production start date based on product lead time" do
      product = create(:product)
      shipment = create(:shipment)
      shipment_item = ShipmentItem.new
      shipment_item.product = product
      shipment_item.shipment = shipment
      production_start = shipment_item.shipment.date - product.total_lead_days
      shipment_item.save
      expect(shipment_item.production_start).to eq(production_start)
    end
  end

  describe "product_duration" do
    it "returns an array of dates" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      expect(shipment_item.product_duration).to eq(Time.zone.today..Time.zone.today + 1.day)
      Timecop.return
    end
  end

  describe "in_production?" do
    it "returns false if item hasn't gone to production" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      Timecop.freeze(Time.zone.now.midnight - 1.day)
      expect(shipment_item.in_production?).to be_falsey
      Timecop.return
    end

    it "returns false if item in production after kickoff_time but it's before kickoff" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      Timecop.freeze(Time.zone.now.midnight + shipment_item.shipment.bakery.kickoff_time.hour.hours - 10.minutes)
      expect(shipment_item.in_production?).to be_falsey
      Timecop.return
    end

    it "returns true if item in production" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      Timecop.freeze(Time.zone.now.midnight + shipment_item.shipment.bakery.kickoff_time.hour.hours + 10.minutes)
      expect(shipment_item.in_production?).to be_truthy
      Timecop.return
    end

    it "returns false if item out of production" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      Timecop.freeze(Time.zone.now.midnight + 2.days)
      expect(shipment_item.in_production?).to be_falsey
      Timecop.return
    end
  end

  describe "after_production?" do
    it "returns false if item hasn't gone to production" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      Timecop.freeze(Time.zone.now.midnight - 1.day)
      expect(shipment_item.after_production?).to be_falsey
      Timecop.return
    end

    it "returns false if item in production production" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      Timecop.freeze(Time.zone.now.midnight + 1.hour)
      expect(shipment_item.after_production?).to be_falsey
      Timecop.return
    end

    it "returns true if item out of production" do
      Timecop.freeze(Time.zone.now.midnight)
      shipment_item.production_start = Time.zone.today
      Timecop.freeze(Time.zone.now.midnight + 2.days)
      expect(shipment_item.after_production?).to be_truthy
      Timecop.return
    end
  end

  describe ".earliest_production_date" do
    it "returns the earliest production date for shipment items collection" do
      shipment = create(:shipment, shipment_item_count: 5)
      shipment_items = shipment.shipment_items
      earliest_shipment_item = shipment_items.order("production_start ASC").first.production_start
      expect(shipment.shipment_items.earliest_production_date).to eq(earliest_shipment_item)
    end
  end
end
