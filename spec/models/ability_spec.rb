require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:competitor) { build(:user) }

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
end
