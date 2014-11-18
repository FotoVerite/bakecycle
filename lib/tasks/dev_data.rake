
namespace :db do
  desc "Reset database with development data"
  task dev_data: :environment do
    raise "don't run this here!" if Rails.env.production?

    Ingredient.delete_all
    FactoryGirl.create_list(:ingredient, 20)
  end
end

