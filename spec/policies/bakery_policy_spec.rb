require 'rails_helper'

describe BakeryPolicy do
  let(:bakery) { build_stubbed(:bakery) }
  let(:record) { build_stubbed(:bakery) }
  let(:policy) { BakeryPolicy.new(current_user, record) }

  context 'When you are an admin' do
    let(:current_user) { build_stubbed(:user, :as_admin, bakery: bakery) }

    it 'has access to bakeries' do
      expect(BakeryPolicy.new(current_user, Bakery)).to authorize(:index)
      expect(BakeryPolicy.new(current_user, Bakery)).to authorize(:new)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    describe 'scope' do
      let(:bakery) { create(:bakery) }
      let(:record) { create(:bakery) }
      let(:current_user) { create(:user, :as_admin, bakery: bakery) }

      it 'returns all the bakeries' do
        expect(policy.scope).to contain_exactly(bakery, record)
      end
    end

    it 'allows you to change bakery plans' do
      expect(policy.permitted_attributes).to include(:plan_id)
    end
  end

  context 'When you do not belong to a bakery' do
    describe 'as an admin' do
      let(:current_user) { build_stubbed(:user, :as_admin, bakery: nil, bakery_permission: 'manage') }
      it 'it allows you to anything' do
        expect(BakeryPolicy.new(current_user, Bakery)).to authorize(:index)
        expect(BakeryPolicy.new(current_user, Bakery)).to authorize(:new)
        expect(policy).to authorize(:show)
        expect(policy).to authorize(:create)
        expect(policy).to authorize(:update)
        expect(policy).to authorize(:edit)
        expect(policy).to authorize(:destroy)
      end

      describe 'scope' do
        let(:bakery) { create(:bakery) }
        let(:record) { create(:bakery) }
        let(:current_user) { create(:user, :as_admin, bakery: nil) }

        it 'returns all the bakeries' do
          expect(policy.scope).to contain_exactly(bakery, record)
        end
      end

      it 'allows you to change bakery plans' do
        expect(policy.permitted_attributes).to include(:plan_id)
      end
    end

    describe 'as a user' do
      let(:current_user) { build_stubbed(:user, bakery: nil, bakery_permission: 'manage') }
      it "with bakery manage access, it doesn't allow you to do anything" do
        expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:index)
        expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:new)
        expect(policy).to_not authorize(:show)
        expect(policy).to_not authorize(:create)
        expect(policy).to_not authorize(:update)
        expect(policy).to_not authorize(:edit)
        expect(policy).to_not authorize(:destroy)
      end

      it "with bakery read access, it doesn't allow you to do anything" do
        current_user.bakery_permission = 'read'
        expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:index)
        expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:new)
        expect(policy).to_not authorize(:show)
        expect(policy).to_not authorize(:create)
        expect(policy).to_not authorize(:update)
        expect(policy).to_not authorize(:edit)
        expect(policy).to_not authorize(:destroy)
      end

      it "As a user with bakery none access, doesn't allow you to do anything" do
        current_user.bakery_permission = 'none'
        expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:index)
        expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:new)
        expect(policy).to_not authorize(:show)
        expect(policy).to_not authorize(:create)
        expect(policy).to_not authorize(:update)
        expect(policy).to_not authorize(:edit)
        expect(policy).to_not authorize(:destroy)
      end

      describe 'scope' do
        let(:bakery) { create(:bakery) }
        let(:record) { create(:bakery) }
        let(:current_user) { create(:user, bakery: nil) }

        it 'returns all the bakeries' do
          expect(policy.scope).to be_empty
        end
      end
    end
  end

  context 'when bakery access level of none' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, bakery_permission: 'none') }
    it "doesn't allow access to bakeries" do
      expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:index)
      expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:new)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'does not allow access to your bakery' do
      policy = BakeryPolicy.new(current_user, bakery)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'never returns any bakeries' do
      bakery = create(:bakery)
      record = create(:bakery)
      current_user = create(:user, bakery: bakery, bakery_permission: 'none')
      policy = BakeryPolicy.new(current_user, record)
      expect(policy.scope).to be_empty
    end
  end

  context 'when bakery access level of read' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, bakery_permission: 'read') }
    it "doesn't allow access to other bakeries" do
      expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:index)
      expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:new)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'does allow read access to your bakery' do
      policy = BakeryPolicy.new(current_user, bakery)
      expect(policy).to authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'only returns your bakery' do
      bakery = create(:bakery)
      record = create(:bakery)
      current_user = create(:user, bakery: bakery, bakery_permission: 'read')
      policy = BakeryPolicy.new(current_user, record)
      expect(policy.scope).to contain_exactly(bakery)
    end
  end

  context 'when bakery access level of manage' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, bakery_permission: 'manage') }
    it "doesn't allow access to bakeries" do
      expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:index)
      expect(BakeryPolicy.new(current_user, Bakery)).to_not authorize(:new)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'does allow access to your bakery' do
      policy = BakeryPolicy.new(current_user, bakery)
      expect(policy).to authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'only returns your bakery' do
      bakery = create(:bakery)
      record = create(:bakery)
      current_user = create(:user, bakery: bakery, bakery_permission: 'manage')
      policy = BakeryPolicy.new(current_user, record)
      expect(policy.scope).to contain_exactly(bakery)
    end

    it "doesn't allows you to change your bakery plan" do
      expect(policy.permitted_attributes).to_not include(:plan_id)
    end
  end
end
