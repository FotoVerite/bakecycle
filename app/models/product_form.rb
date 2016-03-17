class ProductForm
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  attr_accessor :product
  attr_reader :item_finder

  def initialize(product:, user:)
    @product = product
    @item_finder = ItemFinder.new(user)
  end

  def clients
    item_finder.clients.order(name: :asc)
  end

  def serializable_hash
    ProductFormSerializer.new(self).serializable_hash
  end
end
