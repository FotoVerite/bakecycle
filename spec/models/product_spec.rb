require 'rails_helper'

describe Product do
  let(:product) { build(:product) }

  it 'has model attributes' do
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
  end

  it 'has association' do
    expect(product).to belong_to(:bakery)
    expect(product).to belong_to(:motherdough)
    expect(product).to belong_to(:inclusion)
  end

  it 'has validations' do
    expect(product).to validate_presence_of(:name)
    expect(product).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
    expect(product).to validate_presence_of(:product_type)
    expect(product).to validate_presence_of(:base_price)
    expect(product).to validate_presence_of(:weight)
    expect(product).to validate_presence_of(:unit)
    expect(product).to validate_presence_of(:over_bake)
  end

  describe 'name' do
    it 'strips the spaces around names' do
      bread = build(:product, name: ' bread ')
      bread.valid?
      expect(bread.name).to eq('bread')
    end
  end

  describe '#total_lead_days' do
    it 'calculates lead time for a product' do
      motherdough = create(:recipe_motherdough, lead_days: 5)
      inclusion = create(:recipe_inclusion, lead_days: 2)
      product = create(:product, inclusion: inclusion, motherdough: motherdough)
      expect(product.total_lead_days).to eq(5)
    end

    it 'returns 1 if no recipes' do
      expect(product.total_lead_days).to eq(1)
    end
  end

  describe '#price' do
    let(:product) { create(:product, base_price: 10) }

    it 'gives the base price if no variants' do
      expect(product.price(1)).to eq(10)
    end

    it 'returns the matching variant price based upon quantity' do
      create(:price_varient, product: product, price: 9, quantity: 2)
      create(:price_varient, product: product, price: 8, quantity: 3)
      create(:price_varient, product: product, price: 7, quantity: 4)
      expect(product.price(1)).to eq(10)
      expect(product.price(2)).to eq(9)
      expect(product.price(3)).to eq(8)
      expect(product.price(4)).to eq(7)
    end
  end
end
