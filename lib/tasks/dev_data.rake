namespace :db do
  task dev_data: :devdata

  desc "Reset database with development data"
  task devdata: :environment do
    raise "don't run this here!" if Rails.env.production?

    # Things now need to be deleted in order
    ProductionRun.delete_all
    Shipment.delete_all
    Order.delete_all
    Route.delete_all
    Client.delete_all
    Product.delete_all
    Recipe.delete_all
    Ingredient.delete_all
    User.delete_all
    Bakery.delete_all
    Plan.delete_all

    Rails.application.eager_load! # load all classes
    ActiveRecord::Base.descendants.reverse.map(&:destroy_all) # DESTROY ALL CLASSES
    puts "Dev Data Destroyed"

    Rake::Task["bakecycle:create_plans"].invoke
    beta_large = Plan.find_by!(name: "beta_large")
    biencuit = FactoryGirl.create(:bakery, :with_logo, name: "Bien Cuit", plan: beta_large)
    grumpy = FactoryGirl.create(:bakery, name: "Grumpy", plan: beta_large)

    FactoryGirl.create(:user, :as_admin, email: "admin@example.com", bakery: nil)
    FactoryGirl.create(:user, email: "user@example.com", bakery: biencuit)
    FactoryGirl.create(:user, email: "user@biencuit.com", bakery: biencuit)
    FactoryGirl.create(:user, email: "user@grumpy.com", bakery: grumpy)
    DemoCreator.new(biencuit).run
    DemoCreator.new(grumpy).run
    puts "Dev Data Loaded"
  end
end
