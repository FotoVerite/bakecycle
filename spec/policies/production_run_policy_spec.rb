require 'rails_helper'

describe ProductionRunPolicy do
  let(:bakery) { build_stubbed(:bakery) }
  let(:record) { build_stubbed(:production_run, bakery: bakery) }
  let(:policy) { ProductionRunPolicy.new(current_user, record) }

  context 'when you are an admin' do
    context 'that belongs to a bakery' do
      let(:current_user) { build_stubbed(:user, :as_admin, bakery: bakery) }
      it 'has access to production runs it belongs to' do
        expect(ProductionRunPolicy.new(current_user, ProductionRun)).to authorize(:index)
        expect(policy).to authorize(:update)
        expect(policy).to authorize(:edit)
        expect(policy).to authorize(:reset)
        expect(policy).to authorize(:print)
        expect(policy).to authorize(:can_print)
      end

      describe 'scope' do
        it 'returns all production runs of that bakery' do
          bakery = create(:bakery)
          current_user = create(:user, :as_admin, bakery: bakery)
          record = create(:production_run, bakery: bakery)
          policy = ProductionRunPolicy.new(current_user, record)

          expect(policy.scope).to eq [record]
        end
      end
    end

    context 'that does not belong to a bakery' do
      let(:current_user) { build_stubbed(:user, :as_admin, bakery_id: nil) }
      let(:policy) { ProductionRunPolicy.new(current_user, record) }
      it 'has no access when it doesnt belong to a bakery' do
        expect(ProductionRunPolicy.new(current_user, ProductionRun)).to_not authorize(:index)
        expect(policy).to_not authorize(:update)
        expect(policy).to_not authorize(:edit)
        expect(policy).to_not authorize(:reset)
        expect(policy).to_not authorize(:print)
        expect(policy).to_not authorize(:can_print)
      end

      describe 'scope' do
        it 'returns all production runs of that bakery' do
          bakery = create(:bakery)
          current_user = create(:user, :as_admin)
          record = create(:production_run, bakery: bakery)
          policy = ProductionRunPolicy.new(current_user, record)

          expect(policy.scope).to eq []
        end
      end
    end
  end

  context 'when access level of none' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, production_permission: 'none') }
    it 'has no access to production runs' do
      expect(ProductionRunPolicy.new(current_user, ProductionRun)).to_not authorize(:index)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:reset)
      expect(policy).to_not authorize(:print)
      expect(policy).to_not authorize(:can_print)
    end

    describe 'scope' do
      it 'returns none of the production runs of that bakery' do
        bakery = create(:bakery)
        current_user = create(:user, bakery: bakery, production_permission: 'none')
        record = create(:production_run, bakery: bakery)
        policy = ProductionRunPolicy.new(current_user, record)

        expect(policy.scope).to eq []
      end
    end
  end

  context 'when access level of read' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, production_permission: 'read') }
    it 'has some access to production runs' do
      expect(ProductionRunPolicy.new(current_user, ProductionRun)).to authorize(:index)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:reset)
      expect(policy).to authorize(:print)
      expect(policy).to authorize(:can_print)
    end

    describe 'scope' do
      it 'returns all the production runs of that bakery' do
        bakery = create(:bakery)
        current_user = create(:user, bakery: bakery, production_permission: 'read')
        record = create(:production_run, bakery: bakery)
        policy = ProductionRunPolicy.new(current_user, record)

        expect(policy.scope).to eq [record]
      end
    end
  end

  context 'when access level of manage' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, production_permission: 'manage') }
    it 'has access to users' do
      expect(ProductionRunPolicy.new(current_user, ProductionRun)).to authorize(:index)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:reset)
      expect(policy).to authorize(:print)
      expect(policy).to authorize(:can_print)
    end

    describe 'scope' do
      it 'returns all the production runs of that bakery' do
        bakery = create(:bakery)
        current_user = create(:user, bakery: bakery, production_permission: 'read')
        record = create(:production_run, bakery: bakery)
        policy = ProductionRunPolicy.new(current_user, record)

        expect(policy.scope).to eq [record]
      end
    end
  end
end
