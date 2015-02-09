namespace :db do
  task :dev_data, [:devdata]

  desc "Reset database with development data"
  task devdata: :environment do
    raise "don't run this here!" if Rails.env.production?

    Rails.application.eager_load! # load all classes
    ActiveRecord::Base.descendants.map(&:destroy_all) # DESTROY ALL CLASSES
    puts "Dev Data Destroyed"

    biencuit = FactoryGirl.create(:bakery, name: "biencuit")
    grumpy = FactoryGirl.create(:bakery, name: "grumpy")

    FactoryGirl.create(:user, email: 'user@example.com', bakery: biencuit)
    FactoryGirl.create(:user, :as_admin, email: 'admin@example.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'nathan@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'justin@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'kate@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'jane@grumpy.com', bakery: grumpy)
    FactoryGirl.create(:user, email: 'john@grumpy.com', bakery: grumpy)

    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Baguette", bakery: biencuit)
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Brioche", bakery: biencuit)
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Broa", bakery: biencuit)
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Campagne", bakery: biencuit)
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Challah", bakery: biencuit)

    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Black sesame petit pain", bakery: biencuit)
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Chive Lobster Roll", bakery: biencuit)
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Chive Pain au Lait", bakery: biencuit)
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Coriander petit pain", bakery: biencuit)
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Dark Rye", bakery: biencuit)

    FactoryGirl.create(:recipe_preferment, :with_ingredients, name: "Baguette Poolish", bakery: biencuit)
    FactoryGirl.create(:recipe_preferment, name: "Broa Biga", bakery: biencuit)
    FactoryGirl.create(:recipe_preferment, name: "Challah Milk Poolish", bakery: biencuit)
    FactoryGirl.create(:recipe_preferment, name: "Ciabatta Poolish", bakery: biencuit)
    FactoryGirl.create(:recipe_preferment, name: "Ciabatta Wichcraft Poolish", bakery: biencuit)

    FactoryGirl.create(:recipe_ingredient, :with_ingredients, name: "Fennel Seed", bakery: biencuit)
    FactoryGirl.create(:recipe_ingredient, name: "Flour, All Purpose, Unbleached, 25#", bakery: biencuit)
    FactoryGirl.create(:recipe_ingredient, name: "Green Peppercorn", bakery: biencuit)
    FactoryGirl.create(:recipe_ingredient, name: "High Gluten Flour", bakery: biencuit)
    FactoryGirl.create(:recipe_ingredient, name: "Milk Poolish", bakery: biencuit)

    FactoryGirl.create_list(:product, 10, bakery: biencuit)

    FactoryGirl.create(:client, :with_delivery_fee, name: "Mando's Pizza", bakery: biencuit)
    johns_bakery = FactoryGirl.create(:client, name: "John's Bakery", bakery: biencuit)
    angels_deli = FactoryGirl.create(:client, name: "Angel's Deli", bakery: biencuit)
    tonys_brunch = FactoryGirl.create(:client, name: "Tony's Brunch", bakery: biencuit)
    marinas_cafe = FactoryGirl.create(:client, name: "Marina's Cafe", bakery: biencuit)

    route1 = FactoryGirl.create(:route, bakery: biencuit)
    route2 = FactoryGirl.create(:route, bakery: biencuit)
    route3 = FactoryGirl.create(:route, bakery: biencuit)

    FactoryGirl.create(:order, client: johns_bakery, bakery: biencuit, route: route1)
    FactoryGirl.create(:order, client: angels_deli, bakery: biencuit, route: route2)
    FactoryGirl.create(:order, client: tonys_brunch, bakery: biencuit, route: route3)
    FactoryGirl.create(:order, bakery: biencuit)

    FactoryGirl.create_list(:shipment, 20, client: johns_bakery, bakery: biencuit)
    FactoryGirl.create_list(:shipment, 10, client: angels_deli, bakery: biencuit)
    FactoryGirl.create_list(:shipment, 10, client: tonys_brunch, bakery: biencuit)
    FactoryGirl.create_list(:shipment, 10, client: marinas_cafe, bakery: biencuit)
    puts "Dev Data Loaded"
  end
end
