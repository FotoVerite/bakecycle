namespace :db do
  task dev_data: :devdata

  desc 'Reset database with development data'
  task devdata: :environment do
    raise "don't run this here!" if Rails.env.production?

    # Things now need to be deleted in order
    ProductionRun.destroy_all
    Shipment.destroy_all
    Order.destroy_all
    Route.destroy_all
    Client.destroy_all
    Product.destroy_all
    Recipe.destroy_all
    Ingredient.destroy_all
    User.destroy_all
    Bakery.destroy_all

    Rails.application.eager_load! # load all classes
    ActiveRecord::Base.descendants.reverse.map(&:destroy_all) # DESTROY ALL CLASSES
    puts 'Dev Data Destroyed'

    biencuit = FactoryGirl.create(:bakery, :with_logo, name: 'Bien Cuit')
    grumpy = FactoryGirl.create(:bakery, name: 'Grumpy')

    FactoryGirl.create(:user, :as_admin, email: 'admin@example.com', bakery: nil)
    FactoryGirl.create(:user, :as_admin, email: 'admin@bakecycle.com', bakery: nil)
    FactoryGirl.create(:user, :as_admin, email: 'admin@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'user@example.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'user@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'jane@grumpy.com', bakery: grumpy)
    FactoryGirl.create(:user, email: 'john@grumpy.com', bakery: grumpy)

    FactoryGirl.create(:client, :with_delivery_fee, name: "Mando's Pizza", bakery: biencuit)
    johns_bakery = FactoryGirl.create(:client, name: "John's Bakery", bakery: biencuit)
    angels_deli = FactoryGirl.create(:client, :with_delivery_fee, name: "Angel's Deli", bakery: biencuit)
    tonys_brunch = FactoryGirl.create(:client, name: "Tony's Brunch", bakery: biencuit)
    FactoryGirl.create(:client, name: "Marina's Cafe", bakery: biencuit)

    route1 = FactoryGirl.create(:route, bakery: biencuit)
    route2 = FactoryGirl.create(:route, bakery: biencuit, active: false)
    route3 = FactoryGirl.create(:route, bakery: biencuit)

    FactoryGirl.create(:order, client: johns_bakery, bakery: biencuit, route: route1)
    FactoryGirl.create(:order, client: angels_deli, bakery: biencuit, route: route2)
    FactoryGirl.create(:order, client: tonys_brunch, bakery: biencuit, route: route3)
    FactoryGirl.create_list(:order, 12, bakery: biencuit, product_total_lead_days: 5, route: route1)
    FactoryGirl.create_list(:order, 12, product_total_lead_days: 5)

    DemoCreator.new(biencuit).run
    DemoCreator.new(grumpy).run
    KickoffService.run

    puts 'Dev Data Loaded'
  end
end
