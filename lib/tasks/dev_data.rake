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

    FactoryGirl.create(:user, email: 'user@example.com')

    FactoryGirl.create(:recipe_motherdough, name: "Baguette")
    FactoryGirl.create(:recipe_motherdough, name: "Brioche")
    FactoryGirl.create(:recipe_motherdough, name: "Broa")
    FactoryGirl.create(:recipe_motherdough, name: "Campagne")
    FactoryGirl.create(:recipe_motherdough, name: "Challah")

    FactoryGirl.create(:recipe_inclusion, name: "Black sesame petit pain")
    FactoryGirl.create(:recipe_inclusion, name: "Chive Lobster Roll")
    FactoryGirl.create(:recipe_inclusion, name: "Chive Pain au Lait")
    FactoryGirl.create(:recipe_inclusion, name: "Coriander petit pain")
    FactoryGirl.create(:recipe_inclusion, name: "Dark Rye")

    FactoryGirl.create(:recipe_preferment, name: "Baguette Poolish")
    FactoryGirl.create(:recipe_preferment, name: "Broa Biga")
    FactoryGirl.create(:recipe_preferment, name: "Challah Milk Poolish")
    FactoryGirl.create(:recipe_preferment, name: "Ciabatta Poolish")
    FactoryGirl.create(:recipe_preferment, name: "Ciabatta Wichcraft Poolish")

    FactoryGirl.create(:recipe_ingredient, name: "Fennel Seed")
    FactoryGirl.create(:recipe_ingredient, name: "Flour, All Purpose, Unbleached, 25#")
    FactoryGirl.create(:recipe_ingredient, name: "Green Peppercorn")
    FactoryGirl.create(:recipe_ingredient, name: "High Gluten Flour")
    FactoryGirl.create(:recipe_ingredient, name: "Milk Poolish")

    FactoryGirl.create_list(:product, 10)

    johns_bakery = FactoryGirl.create(:client, name: "John's Bakery")
    angels_deli = FactoryGirl.create(:client, name: "Angel's Deli")
    tonys_brunch = FactoryGirl.create(:client, name: "Tony's Brunch")
    FactoryGirl.create(:client, name: "Michelle's Pretzels")
    FactoryGirl.create(:client, name: "Marina's Cafe")

    FactoryGirl.create(:order, client: johns_bakery)
    FactoryGirl.create(:order, client: angels_deli)
    FactoryGirl.create(:order, client: tonys_brunch)
  end
end
