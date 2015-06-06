require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:competitor) { build(:user) }

  describe 'managing bakeries' do
    it 'allows users to edit their own bakery' do
      expect(ability).to be_able_to(:edit, user.bakery)
      expect(ability).to be_able_to(:read, user.bakery)
      expect(ability).to_not be_able_to(:destroy, user.bakery)
      expect(ability).to_not be_able_to(:create, Bakery)
      expect(ability).to_not be_able_to(:read, build(:bakery))
    end

    context 'no bakery' do
      let(:user) { create(:user, bakery: nil) }
      it "doesn't allow them to do anything" do
        expect(ability).to_not be_able_to(:create, user.bakery)
        expect(ability).to_not be_able_to(:read, user.bakery)
        expect(ability).to_not be_able_to(:update, user.bakery)
        expect(ability).to_not be_able_to(:delete, user.bakery)
        expect(ability).to_not be_able_to(:manage, user.bakery)
      end
    end

    context 'admin' do
      let(:user) { create(:user, :as_admin) }
      it 'allows them to do anything' do
        expect(ability).to be_able_to(:manage, user.bakery)
        expect(ability).to be_able_to(:manage, build(:bakery))
      end
    end
  end

  describe 'managing users' do
    it 'allows users to manage users in their bakery except themselves' do
      coworker = build(:user, bakery: user.bakery)
      no_bakery_user = build(:user, bakery: nil)

      expect(ability).to be_able_to(:manage, coworker)
      expect(ability).to_not be_able_to(:destroy, user)
      expect(ability).to_not be_able_to(:manage, competitor)
      expect(ability).to_not be_able_to(:manage, no_bakery_user)
    end

    it 'allows users to update and read themselves' do
      expect(ability).to be_able_to(:update, user)
      expect(ability).to be_able_to(:read, user)
    end

    it 'allows creation of clients only for their own bakery' do
      expect(ability).to be_able_to(:create, User.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, User.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, User)).to eq(bakery_id: user.bakery.id)
    end

    context 'no bakery' do
      let(:user) { create(:user, bakery: nil) }

      it 'can only manage themselves' do
        other_no_bakery_user = build(:user, bakery: nil)
        expect(ability).to be_able_to(:read, user)
        expect(ability).to be_able_to(:update, user)
        expect(ability).to_not be_able_to(:manage, competitor)
        expect(ability).to_not be_able_to(:manage, other_no_bakery_user)
      end
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to manage all users' do
        no_bakery_user = build(:user, bakery: nil)
        expect(ability).to be_able_to(:manage, user)
        expect(ability).to be_able_to(:manage, competitor)
        expect(ability).to be_able_to(:manage, no_bakery_user)
      end
    end

    context 'collections' do
      let(:user) { create(:user) }
      let(:competitor) { create(:user) }

      it 'allows users to see users in their bakery' do
        coworkers = create_list(:user, 2, bakery: user.bakery)
        expect(User.accessible_by(ability)).to contain_exactly(*coworkers, user)
      end

      it 'shows no users if there is no bakery' do
        no_bakery_user = build(:user, bakery: nil)
        create(:user)
        ability_2 = Ability.new(no_bakery_user)
        expect(User.accessible_by(ability_2)).to be_empty
      end

      context 'admins' do
        let(:user) { create(:user, :as_admin) }
        it 'allows admins to see all users' do
          expect(User.accessible_by(ability)).to contain_exactly(user, competitor)
        end
      end
    end
  end

  describe 'managing clients' do
    let(:client) { create(:client, bakery: user.bakery) }
    let(:competitor_client) { create(:client, bakery: competitor.bakery) }

    it 'allows managing clients from same bakery' do
      expect(ability).to be_able_to(:manage, client)
      expect(ability).to_not be_able_to(:manage, competitor_client)
      expect(Client.accessible_by(ability)).to contain_exactly(client)
    end

    it 'allows creation of clients only for their own bakery' do
      expect(ability).to be_able_to(:create, Client.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, Client.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, Client)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows managing clients from same bakery' do
        expect(ability).to be_able_to(:manage, client)
        expect(ability).to_not be_able_to(:manage, competitor_client)
        expect(Client.accessible_by(ability)).to contain_exactly(client)
      end
    end
  end

  describe 'managing ingredients' do
    let(:ingredient) { create(:ingredient, bakery: user.bakery) }
    let(:competitor_ingredient) { create(:ingredient, bakery: competitor.bakery) }

    it 'allows users to access ingredients from same bakery' do
      ingredient_2 = create(:ingredient, bakery: user.bakery)
      expect(Ingredient.accessible_by(ability)).to contain_exactly(ingredient, ingredient_2)
    end

    it 'allows creation of ingredients only for their own bakery' do
      expect(ability).to be_able_to(:create, Ingredient.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, Ingredient.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, Ingredient)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery ingredients' do
        ingredient_2 = create(:ingredient, bakery: user.bakery)
        expect(Ingredient.accessible_by(ability)).to contain_exactly(ingredient, ingredient_2)
      end
    end
  end

  describe 'managing orders' do
    let(:order) { create(:order, bakery: user.bakery) }
    let(:competitor_order) { create(:order, bakery: competitor.bakery) }

    it 'allows users to access orders from same bakery' do
      order_2 = create(:order, bakery: user.bakery)
      expect(Order.accessible_by(ability)).to contain_exactly(order, order_2)
    end

    it 'allows creation of orders only for their own bakery' do
      expect(ability).to be_able_to(:create, Order.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, Order.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, Order)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery orders' do
        order_2 = create(:order, bakery: user.bakery)
        expect(Order.accessible_by(ability)).to contain_exactly(order, order_2)
      end
    end
  end

  describe 'managing products' do
    let(:product) { create(:product, bakery: user.bakery) }
    let(:competitor_product) { create(:product, bakery: competitor.bakery) }

    it 'allows users to access products from same bakery' do
      product_2 = create(:product, bakery: user.bakery)
      expect(Product.accessible_by(ability)).to contain_exactly(product, product_2)
    end

    it 'allows creation of products only for their own bakery' do
      expect(ability).to be_able_to(:create, Product.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, Product.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, Product)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery products' do
        product_2 = create(:product, bakery: user.bakery)
        expect(Product.accessible_by(ability)).to contain_exactly(product, product_2)
      end
    end
  end

  describe 'managing recipes' do
    let(:recipe) { create(:recipe, bakery: user.bakery) }
    let(:competitor_recipe) { create(:recipe, bakery: competitor.bakery) }

    it 'allows users to access recipes from same bakery' do
      recipe_2 = create(:recipe, bakery: user.bakery)
      expect(Recipe.accessible_by(ability)).to contain_exactly(recipe, recipe_2)
    end

    it 'allows creation of recipes only for their own bakery' do
      expect(ability).to be_able_to(:create, Recipe.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, Recipe.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, Recipe)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery recipes' do
        recipe_2 = create(:recipe, bakery: user.bakery)
        expect(Recipe.accessible_by(ability)).to contain_exactly(recipe, recipe_2)
      end
    end
  end

  describe 'managing routes' do
    let(:route) { create(:route, bakery: user.bakery) }
    let(:competitor_route) { create(:route, bakery: competitor.bakery) }

    it 'allows users to access routes from same bakery' do
      route_2 = create(:route, bakery: user.bakery)
      expect(Route.accessible_by(ability)).to contain_exactly(route, route_2)
    end

    it 'allows creation of routes only for their own bakery' do
      expect(ability).to be_able_to(:create, Route.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, Route.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, Route)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery routes' do
        route_2 = create(:route, bakery: user.bakery)
        expect(Route.accessible_by(ability)).to contain_exactly(route, route_2)
      end
    end
  end

  describe 'managing shipments' do
    let(:shipment) { create(:shipment, bakery: user.bakery) }
    let(:competitor_shipment) { create(:shipment, bakery: competitor.bakery) }

    it 'allows users to access shipments from same bakery' do
      shipment_2 = create(:shipment, bakery: user.bakery)
      expect(Shipment.accessible_by(ability)).to contain_exactly(shipment, shipment_2)
    end

    it 'allows creation of shipment only for their own bakery' do
      expect(ability).to be_able_to(:create, Shipment.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, Shipment.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, Shipment)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery shipments' do
        shipment_2 = create(:shipment, bakery: user.bakery)
        expect(Shipment.accessible_by(ability)).to contain_exactly(shipment, shipment_2)
      end
    end
  end

  describe 'managing production runs' do
    let(:production_run) { create(:production_run, bakery: user.bakery) }
    let(:competitor_production_run) { create(:production_run, bakery: competitor.bakery) }

    it 'allows users to access production run from same bakery' do
      production_run_2 = create(:production_run, bakery: user.bakery)
      expect(ProductionRun.accessible_by(ability)).to contain_exactly(production_run, production_run_2)
    end

    it 'allows creation of shipment only for their own bakery' do
      expect(ability).to be_able_to(:create, ProductionRun.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, ProductionRun.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, ProductionRun)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery shipments' do
        production_run_2 = create(:production_run, bakery: user.bakery)
        expect(ProductionRun.accessible_by(ability)).to contain_exactly(production_run, production_run_2)
      end
    end
  end

  describe 'managing file exports' do
    let(:file_export) { create(:file_export, bakery: user.bakery) }
    let(:competitor_file_export) { create(:file_export, bakery: competitor.bakery) }

    it 'allows users to access production run from same bakery' do
      file_export_2 = create(:file_export, bakery: user.bakery)
      expect(FileExport.accessible_by(ability)).to contain_exactly(file_export, file_export_2)
    end

    it 'allows creation of shipment only for their own bakery' do
      expect(ability).to be_able_to(:create, FileExport.new(bakery: user.bakery))
      expect(ability).to_not be_able_to(:create, FileExport.new(bakery: competitor.bakery))
      expect(ability.attributes_for(:create, FileExport)).to eq(bakery_id: user.bakery.id)
    end

    context 'admins' do
      let(:user) { create(:user, :as_admin) }
      it 'allows admins to see only their bakery shipments' do
        file_export_2 = create(:file_export, bakery: user.bakery)
        expect(FileExport.accessible_by(ability)).to contain_exactly(file_export, file_export_2)
      end
    end
  end
end
