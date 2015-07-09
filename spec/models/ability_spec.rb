require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:competitor) { build(:user) }

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
