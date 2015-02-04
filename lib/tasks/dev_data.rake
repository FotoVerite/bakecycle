namespace :db do
  task :dev_data, [:devdata]

  desc "Reset database with development data"
  task devdata: :environment do
    raise "don't run this here!" if Rails.env.production?

    User.delete_all
    Ingredient.delete_all
    Recipe.delete_all
    Product.delete_all
    Route.delete_all
    Client.delete_all
    Order.delete_all
    Shipment.delete_all
    Bakery.delete_all

    biencuit = FactoryGirl.create(:bakery, name: "biencuit")
    grumpy = FactoryGirl.create(:bakery, name: "grumpy")

    FactoryGirl.create(:user, email: 'user@example.com', bakery: biencuit)
    FactoryGirl.create(:user, :as_admin, email: 'admin@example.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'nathan@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'justin@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'kate@biencuit.com', bakery: biencuit)
    FactoryGirl.create(:user, email: 'jane@grumpy.com', bakery: grumpy)
    FactoryGirl.create(:user, email: 'john@grumpy.com', bakery: grumpy)

    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Baguette")
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Brioche")
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Broa")
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Campagne")
    FactoryGirl.create(:recipe_motherdough, :with_ingredients, name: "Challah")

    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Black sesame petit pain")
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Chive Lobster Roll")
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Chive Pain au Lait")
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Coriander petit pain")
    FactoryGirl.create(:recipe_inclusion, :with_ingredients, name: "Dark Rye")

    FactoryGirl.create(:recipe_preferment, :with_ingredients, name: "Baguette Poolish")
    FactoryGirl.create(:recipe_preferment, name: "Broa Biga")
    FactoryGirl.create(:recipe_preferment, name: "Challah Milk Poolish")
    FactoryGirl.create(:recipe_preferment, name: "Ciabatta Poolish")
    FactoryGirl.create(:recipe_preferment, name: "Ciabatta Wichcraft Poolish")

    FactoryGirl.create(:recipe_ingredient, :with_ingredients, name: "Fennel Seed")
    FactoryGirl.create(:recipe_ingredient, name: "Flour, All Purpose, Unbleached, 25#")
    FactoryGirl.create(:recipe_ingredient, name: "Green Peppercorn")
    FactoryGirl.create(:recipe_ingredient, name: "High Gluten Flour")
    FactoryGirl.create(:recipe_ingredient, name: "Milk Poolish")

    FactoryGirl.create_list(:product, 10)

    johns_bakery = FactoryGirl.create(:client, name: "John's Bakery")
    angels_deli = FactoryGirl.create(:client, name: "Angel's Deli")
    tonys_brunch = FactoryGirl.create(:client, name: "Tony's Brunch")
    marinas_cafe = FactoryGirl.create(:client, name: "Marina's Cafe")
    FactoryGirl.create(:client, name: "Michelle's Pretzels")

    FactoryGirl.create(:order, client: johns_bakery)
    FactoryGirl.create(:order, client: angels_deli)
    FactoryGirl.create(:order, client: tonys_brunch)

    FactoryGirl.create_list(:shipment, 20, client: johns_bakery)
    FactoryGirl.create_list(:shipment, 10, client: angels_deli)
    FactoryGirl.create_list(:shipment, 10, client: tonys_brunch)
    FactoryGirl.create_list(:shipment, 10, client: marinas_cafe)
    puts "Dev Data loaded"
  end
end
