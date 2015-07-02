require 'rails_helper'

describe UserPolicy do
  let(:bakery) { build_stubbed(:bakery) }
  let(:record) { build_stubbed(:user, bakery: bakery) }
  let(:policy) { UserPolicy.new(current_user, record) }

  context 'when you are an admin' do
    let(:current_user) { build_stubbed(:user, :as_admin, bakery: bakery) }
    it 'has access to users' do
      expect(UserPolicy.new(current_user, User)).to authorize(:index)
      expect(UserPolicy.new(current_user, User)).to authorize(:new)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it 'has access to users in other bakeries' do
      record = build_stubbed(:user)
      policy = UserPolicy.new(current_user, record)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it 'does allow access to yourself' do
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it 'returns all users from all bakeries' do
      bakery_1 = create(:bakery)
      bakery_2 = create(:bakery)

      current_user = create(:user, :as_admin)
      record_1 = create(:user, bakery: bakery_1)
      record_2 = create(:user, bakery: bakery_2)

      policy = UserPolicy.new(current_user, record)
      expect(policy.scope).to contain_exactly(record_2, current_user, record_1)
    end

    it 'allows you to change the bakery' do
      expect(policy.permitted_attributes).to include(:bakery_id)
    end
    it 'allows you to set user_permission level' do
      expect(policy.permitted_attributes).to include(:user_permission, :product_permission)
    end
  end

  context 'when access level of none' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, user_permission: 'none') }
    it "doesn't allow access to users" do
      expect(UserPolicy.new(current_user, User)).to_not authorize(:index)
      expect(UserPolicy.new(current_user, User)).to_not authorize(:new)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'does allow access to yourself' do
      record = current_user
      policy = UserPolicy.new(current_user, record)
      expect(policy).to authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it 'never returns any users but yourself' do
      bakery = create(:bakery)
      current_user = create(:user, bakery: bakery, user_permission: 'none')
      record = create(:user, bakery: bakery)
      policy = UserPolicy.new(current_user, record)
      expect(policy.scope).to contain_exactly(current_user)
    end

    it "doesn't allow you to change the bakery" do
      expect(policy.permitted_attributes).to_not include(:bakery_id)
    end
    it "doesn't allow you to set user_permission level" do
      expect(policy.permitted_attributes).to_not include(:user_permission)
    end
  end

  context 'when access level of read' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, user_permission: 'read') }
    it 'has access to users' do
      expect(UserPolicy.new(current_user, User)).to authorize(:index)
      expect(UserPolicy.new(current_user, User)).to_not authorize(:new)
      expect(policy).to authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it 'does allow access to yourself' do
      record = current_user
      policy = UserPolicy.new(current_user, record)
      expect(policy).to authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it 'returns all users' do
      bakery = create(:bakery)
      current_user = create(:user, bakery: bakery, user_permission: 'read')
      record = create(:user, bakery: bakery)
      policy = UserPolicy.new(current_user, record)
      expect(policy.scope).to contain_exactly(current_user, record)
    end

    it "doesn't allow you to change the bakery" do
      expect(policy.permitted_attributes).to_not include(:bakery_id)
    end

    it "doesn't allow you to set user_permission level" do
      expect(policy.permitted_attributes).to_not include(:user_permission)
    end
  end

  context 'when access level of manage' do
    let(:current_user) { build_stubbed(:user, bakery: bakery, user_permission: 'manage') }
    it 'has access to users' do
      expect(UserPolicy.new(current_user, User)).to authorize(:index)
      expect(UserPolicy.new(current_user, User)).to authorize(:new)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it 'does allow access to yourself' do
      record = current_user
      policy = UserPolicy.new(current_user, record)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it 'returns all users' do
      bakery = create(:bakery)
      current_user = create(:user, bakery: bakery, user_permission: 'manage')
      record = create(:user, bakery: bakery)
      policy = UserPolicy.new(current_user, record)
      expect(policy.scope).to contain_exactly(current_user, record)
    end

    it "doesn't allow you to change the bakery" do
      expect(policy.permitted_attributes).to_not include(:bakery_id)
    end

    it 'allows you to set user_permission level' do
      expect(policy.permitted_attributes).to include(:user_permission, :product_permission)
    end
  end
end
