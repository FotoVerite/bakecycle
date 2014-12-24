class OrderCreator
  attr_reader :routes, :clients, :products

  def initialize
    @routes = Route.all
    @clients = Client.all
    @products = Product.all
  end
end
