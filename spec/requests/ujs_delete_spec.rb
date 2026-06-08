# frozen_string_literal: true

require "rails_helper"

# These specs verify that the DELETE endpoints work correctly after switching from
# jquery_ujs to rails-ujs. rails-ujs generates a form with _method=DELETE and
# submits it; these specs confirm the Rails controller side handles those requests.
RSpec.describe "UJS delete links", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }

  before { sign_in user }

  describe "sign out" do
    it "destroys the session and redirects to root" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path(message: true))
    end

    it "does not allow further authenticated requests after sign out" do
      delete destroy_user_session_path
      get clients_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "client destroy" do
    # set_client uses joins(:shipments) so the client must have at least one shipment
    let(:client) { create(:client, bakery: bakery) }
    before { create(:shipment, bakery: bakery, client: client) }

    it "deletes the client and redirects to clients list" do
      delete client_path(client)
      expect(response).to redirect_to(clients_path)
      expect(Client.find_by(id: client.id)).to be_nil
    end
  end

  describe "shipment destroy (HTML)" do
    let(:shipment) { create(:shipment, bakery: bakery) }

    it "deletes the shipment and redirects to invoices list" do
      delete "/invoices/#{shipment.id}"
      expect(response).to redirect_to(shipments_path)
      expect(Shipment.find_by(id: shipment.id)).to be_nil
    end
  end

  describe "shipment destroy (JS — remote: true link)" do
    let(:shipment) { create(:shipment, bakery: bakery) }

    it "deletes the shipment and returns JS response" do
      delete "/invoices/#{shipment.id}", headers: { "Accept" => "text/javascript" }
      expect(response).to be_successful
      expect(Shipment.find_by(id: shipment.id)).to be_nil
    end
  end

  describe "user destroy" do
    let(:admin) { create(:user, :as_admin, bakery: bakery) }
    let(:target_user) { create(:user, bakery: bakery) }

    before { sign_in admin }

    it "deletes the user and redirects to users list" do
      delete user_path(target_user)
      expect(response).to redirect_to(users_path)
      expect(User.find_by(id: target_user.id)).to be_nil
    end
  end

  describe "recipe destroy" do
    let(:recipe) { create(:recipe, bakery: bakery) }

    it "deletes the recipe and redirects to recipes list" do
      delete recipe_path(recipe)
      expect(response).to redirect_to(recipes_path)
      expect(Recipe.find_by(id: recipe.id)).to be_nil
    end
  end

  describe "product destroy" do
    # Product model requires inactive: true before it can be destroyed.
    # Destroy is a soft-delete: sets removed: true rather than deleting the row.
    let(:product) { create(:product, bakery: bakery, inactive: true) }

    it "marks the product as removed and redirects to products list" do
      delete product_path(product)
      expect(response).to redirect_to(products_path)
      expect(product.reload.removed).to be true
    end
  end

  describe "vendor destroy" do
    let(:vendor) { create(:vendor, bakery: bakery) }

    it "deletes the vendor and redirects to vendors list" do
      delete vendor_path(vendor)
      expect(response).to redirect_to(vendors_path)
      expect(Vendor.find_by(id: vendor.id)).to be_nil
    end
  end

  describe "order destroy" do
    let(:order) { create(:order, bakery: bakery) }

    it "deletes the order and redirects to orders list" do
      delete order_path(order)
      expect(response).to redirect_to(orders_path)
      expect(Order.find_by(id: order.id)).to be_nil
    end
  end

  describe "ingredient destroy" do
    let(:ingredient) { create(:ingredient, bakery: bakery) }

    it "deletes the ingredient and redirects to ingredients list" do
      delete ingredient_path(ingredient)
      expect(response).to redirect_to(ingredients_path)
      expect(Ingredient.find_by(id: ingredient.id)).to be_nil
    end
  end

  describe "route destroy" do
    # RoutesController blocks deletion of the last remaining route; create two.
    let!(:route) { create(:route, bakery: bakery) }
    let!(:other_route) { create(:route, bakery: bakery) }

    it "deletes the route and redirects to routes list" do
      delete route_path(route)
      expect(response).to redirect_to(routes_path)
      expect(Route.find_by(id: route.id)).to be_nil
    end
  end

  describe "bakery destroy" do
    let(:admin) { create(:user, :as_admin, bakery: bakery) }
    let(:other_bakery) { create(:bakery) }

    before { sign_in admin }

    it "deletes the bakery and redirects to bakeries list" do
      delete bakery_path(other_bakery)
      expect(response).to redirect_to(bakeries_path)
      expect(Bakery.find_by(id: other_bakery.id)).to be_nil
    end
  end

  # NOTE: devise/registrations/edit.html.erb has a "Cancel my account" delete link,
  # but :registerable is not included in User's devise modules, so no
  # user_registration DELETE route exists. The link would raise a routing error.
  # Pre-existing bug — requires adding :registerable to devise or removing the view.

  # NOTE: production_runs/_form.html.erb has a delete link pointing to
  # production_run_path, but routes.rb only allows [:index, :edit, :update]
  # for production_runs — there is no DELETE route. The link would 404.
  # Pre-existing bug — requires adding destroy to production_runs routes or removing the link.
end
