
namespace :db do
  desc "Reset database with development data"
  task dev_data: :environment do
    raise "don't run this here!" if Rails.env.production?

    Ingredient.delete_all
    Recipe.delete_all
    Product.delete_all
    FactoryGirl.create_list(:ingredient, 20)
    FactoryGirl.create_list(:recipe_motherdough, 5)
    FactoryGirl.create_list(:recipe_inclusion, 5)
    FactoryGirl.create_list(:recipe_preferment, 5)
    FactoryGirl.create_list(:recipe_ingredient, 5)
    FactoryGirl.create_list(:product, 10)
  end
end

