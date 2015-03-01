require 'rails_helper'

describe AlphabeticalOrder do
  describe '.order_by_name' do
    it 'returns a list in alphabetical name order for products' do
      product1 = create(:product, name: 'Banana Cake')
      product2 = create(:product, name: 'Apple Pie')
      product3 = create(:product, name: 'Ginger Cookies')
      expect(Product.order_by_name).to eq([product2, product1, product3])
    end
  end
end
