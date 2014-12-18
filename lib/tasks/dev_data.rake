
namespace :db do
  desc "Reset database with development data"
  task dev_data: :environment do
    raise "don't run this here!" if Rails.env.production?

    User.delete_all
    Ingredient.delete_all
    Recipe.delete_all
    Product.delete_all
    Route.delete_all
    Client.delete_all
    Order.delete_all

    create(:user, email: 'user@example.com')
    create_list(:ingredient, 20)
    create_list(:recipe_motherdough, 5)
    create_list(:recipe_inclusion, 5)
    create_list(:recipe_preferment, 5)
    create_list(:recipe_ingredient, 5)
    create_list(:product, 10)
    create_list(:route, 5)
    create_list(:client, 5)
    create_list(:order, 5)
  end
end
