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
    expect(product).to respond_to(:motherdough)
    expect(product).to respond_to(:inclusion)
    expect(product).to respond_to(:base_price)
    expect(product).to respond_to(:sku)
    expect(product).to belong_to(:bakery)
    expect(product).to belong_to(:motherdough)
    expect(product).to belong_to(:inclusion)
  end

  it "has validations" do
    expect(product).to validate_presence_of(:name)
    product.name = "a name"
    expect(product).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
    expect(product).to validate_presence_of(:product_type)
    expect(product).to validate_presence_of(:base_price)
    expect(product).to validate_presence_of(:weight)
    expect(product).to validate_presence_of(:unit)
    expect(product).to validate_presence_of(:over_bake)
  end

  describe "#destroy" do
    it "wont destroy if it's used in an order" do
      bakery = create(:bakery)
      product = create(:product, bakery: bakery)
      order = create(:order, bakery: bakery)
      order.order_items.first.update!(product: product)
      expect(product.destroy).to eq(false)
      expect(product.errors.to_a).to eq(["This product is still used in orders"])
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
      dough = FactoryGirl.create(:recipe_motherdough)
      product = FactoryGirl.create(:product, motherdough: dough)

      expect(Resque).to receive(:enqueue).at_least(:once).and_call_original
      dough.update(lead_days: 9)
      product.reload
      expect(product.total_lead_days).to eq(9)
    end
  end

  describe ResqueJobs do
    describe "#async" do
      let(:product) { create(:product) }
      it "enqueues the job" do
        expect(Resque).to receive(:enqueue).with(Product, product.id, :wohhh, :dude)
        product.async(:wohhh, :dude)
      end
    end

    describe ".perform" do
      it "fetches the id and runs the method" do
        expect(Product).to receive(:find).with(4).and_return(product)
        expect(product).to receive(:price).with(:wohhh, :dude)
        Product.perform(4, :price, :wohhh, :dude)
      end

      it "re-enqueues itself when terminated" do
        id = 5
        method = :wohhh
        expect(Product).to receive(:find).and_raise(Resque::TermException, "TERM")
        expect(Resque).to receive(:enqueue).with(Product, id, method)
        Product.perform(id, method)
      end
    end
  end
end
