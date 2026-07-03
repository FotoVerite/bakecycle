# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  product_type    :integer          not null
#  weight          :decimal(, )      not null
#  unit            :integer          not null
#  description     :text
#  over_bake       :decimal(, )      default(0.0), not null
#  motherdough_id  :integer
#  inclusion_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  base_price      :decimal(, )      not null
#  bakery_id       :integer          not null
#  sku             :string
#  legacy_id       :string
#  total_lead_days :integer          not null
#  batch_recipe    :boolean          default(FALSE)
#  removed         :boolean          default(FALSE)
#  graph_data      :json
#

require "rails_helper"

describe Product do
  let(:bakery) { build(:bakery) }
  let(:product) { build(:product, bakery: bakery) }

  it "has a shape" do
    expect(product).to respond_to(:name)
    expect(product).to respond_to(:product_type)
    expect(product).to respond_to(:description)
    expect(product).to respond_to(:weight)
    expect(product).to respond_to(:unit)
    expect(product).to respond_to(:over_bake)
    expect(product).to respond_to(:pieces_per_tray)
    expect(product).to respond_to(:motherdough)
    expect(product).to respond_to(:inclusion)
    expect(product).to respond_to(:base_price)
    expect(product).to respond_to(:sku)
    expect(product).to belong_to(:bakery)
    expect(product).to belong_to(:motherdough).optional
    expect(product).to belong_to(:inclusion).optional
  end

  it "has validations" do
    expect(product).to validate_presence_of(:name)
    product.name = "a name"
    expect(create(:product, bakery: create(:bakery),
                            name: "a name")).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
    expect(product).to validate_presence_of(:product_type)
    expect(product).to validate_presence_of(:base_price)
    expect(product).to validate_presence_of(:weight)
    expect(product).to validate_presence_of(:unit)
    expect(product).to validate_presence_of(:over_bake)
    expect(product).to allow_value(nil).for(:pieces_per_tray)
    expect(product).to allow_value(60).for(:pieces_per_tray)
    expect(product).to_not allow_value(0).for(:pieces_per_tray)
    expect(product).to_not allow_value(-1).for(:pieces_per_tray)
    expect(product).to_not allow_value(1.5).for(:pieces_per_tray)
  end

  describe "#destroy" do
    it "wont destroy if it's used in an order" do
      # TODO: make this state impossible to get into.
      bakery = create(:bakery)
      product = create(:product, bakery: bakery, inactive: true)
      order = create(:order, bakery: bakery, order_item_count: 1)
      order.order_items.first.update!(product: product)
      expect(product.destroy).to eq(false)
      expect(product.errors.to_a).to eq(["This product is still used in orders"])
    end

    it "wont destroy if it's listed as active" do
      bakery = create(:bakery)
      product = create(:product, bakery: bakery, inactive: false)
      expect(product.destroy).to eq(false)
      expect(product.errors.to_a).to eq(["product must first be set to inactive!"])
    end

    it "destroy if it's listed as inactive and has no orders" do
      bakery = create(:bakery)
      product = create(:product, bakery: bakery, inactive: true)
      expect(product.destroy).to eq(true)
    end
  end

  describe "name" do
    it "strips the spaces around names" do
      bread = build(:product, name: " bread ")
      bread.valid?
      expect(bread.name).to eq("bread")
    end
  end

  describe "lead days" do
    let(:bakery) { create(:bakery) }

    it "calculates lead time for a product" do
      motherdough = create(:recipe_motherdough, lead_days: 5, bakery: bakery)
      inclusion = create(:recipe_inclusion, lead_days: 2, bakery: bakery)
      product = create(:product, inclusion: inclusion, motherdough: motherdough, bakery: bakery)
      expect(product.total_lead_days).to eq(5)
    end

    it "returns 1 if no recipes" do
      product.save
      expect(product.total_lead_days).to eq(1)
    end

    it "updates when products are removed" do
      product = create(:product, :with_motherdough, force_total_lead_days: 5)
      expect(product.total_lead_days).to eq(5)
      product.update!(motherdough: nil)
      expect(product.total_lead_days).to eq(1)
    end
  end

  describe ".price(qty, client)" do
    let(:product) { create(:product, base_price: 10) }
    let(:client_1) { create(:client) }
    let(:client_2) { create(:client) }

    it "gives the base price if no variants" do
      expect(product.price(1, client_1)).to eq(10)
    end

    it "returns the matching variant price based upon quantity and client" do
      create(:price_variant, product: product, price: 2, quantity: 50)
      create(:price_variant, product: product, client: client_1, price: 9, quantity: 10)
      create(:price_variant, product: product, client: client_1, price: 8, quantity: 15)
      create(:price_variant, product: product, client: client_1, price: 7, quantity: 20)
      create(:price_variant, product: product, client: client_2, price: 5, quantity: 10)
      create(:price_variant, product: product, client: client_2, price: 4, quantity: 15)
      create(:price_variant, product: product, client: client_2, price: 3, quantity: 20)

      expect(product.price(1, client_1)).to eq(10)
      expect(product.price(9, client_1)).to eq(10)
      expect(product.price(13, client_1)).to eq(9)
      expect(product.price(20, client_1)).to eq(7)
      expect(product.price(21, client_1)).to eq(7)
      expect(product.price(1, client_2)).to eq(10)
      expect(product.price(9, client_2)).to eq(10)
      expect(product.price(13, client_2)).to eq(5)
      expect(product.price(20, client_2)).to eq(3)
      expect(product.price(25, client_2)).to eq(3)
      expect(product.price(50, client_2)).to eq(2)
      expect(product.price(50, client_1)).to eq(2)
    end
  end

  describe "after touch" do
    it "updates its total lead days based on the motherdough" do
      dough = FactoryBot.create(:recipe_motherdough)
      product = FactoryBot.create(:product, motherdough: dough)

      expect(ModelMethodJob).to receive(:perform_later).at_least(:once).and_call_original
      dough.update(lead_days: 9)
      product.reload
      expect(product.total_lead_days).to eq(9)
    end
  end

  describe "#async" do
    let(:product) { create(:product) }
    it "enqueues a ModelMethodJob" do
      expect(ModelMethodJob).to receive(:perform_later).with("Product", product.id, "wohhh", :dude)
      product.async(:wohhh, :dude)
    end
  end

  describe "#bake_lead_days_for" do
    it "falls back to the product's own default when no client override exists" do
      product = create(:product, bake_lead_days: 1)
      client = create(:client, bakery: product.bakery)

      expect(product.bake_lead_days_for(client)).to eq(1)
    end

    it "uses a client-specific override when one exists (the Baguette case)" do
      product = create(:product, bake_lead_days: 1)
      retail_client = create(:client, bakery: product.bakery)
      wholesale_client = create(:client, bakery: product.bakery)
      create(:bake_lead_day_variant, product: product, client: retail_client, bake_lead_days: 0)

      expect(product.bake_lead_days_for(retail_client)).to eq(0)
      expect(product.bake_lead_days_for(wholesale_client)).to eq(1)
    end

    it "ignores a removed override" do
      product = create(:product, bake_lead_days: 1)
      client = create(:client, bakery: product.bakery)
      create(:bake_lead_day_variant, product: product, client: client, bake_lead_days: 0, removed: 1)

      expect(product.bake_lead_days_for(client)).to eq(1)
    end
  end

  describe "#trays_for" do
    it "returns nil when the product isn't tray-tracked" do
      product = build(:product, pieces_per_tray: nil)
      expect(product.trays_for(40)).to be_nil
    end

    it "formats an exact multiple with no remainder" do
      product = build(:product, pieces_per_tray: 20)
      expect(product.trays_for(40)).to eq("2 trays")
    end

    it "formats a remainder" do
      product = build(:product, pieces_per_tray: 20)
      expect(product.trays_for(45)).to eq("2 trays + 5 pcs")
    end
  end
end
