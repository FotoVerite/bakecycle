require 'rails_helper'

describe OrderCreator do
  let(:order_creator) { OrderCreator.new }

  it "has model attributes" do
    expect(order_creator).to respond_to(:routes)
    expect(order_creator).to respond_to(:clients)
    expect(order_creator).to respond_to(:products)
  end

  it "list all routes" do
    routes = create_list(:route, 5)
    expect(order_creator.routes).to eq(routes)
  end

  it "list all clients" do
    clients = create_list(:client, 3)
    expect(order_creator.clients).to eq(clients)
  end

  it "list all products" do
    products = create_list(:product, 10)
    expect(order_creator.products).to eq(products)
  end
end
