require "rails_helper"

describe ShippingPolicy do
  let(:bakery) { build_stubbed(:bakery) }
  let(:record) { build_stubbed(:route, bakery: bakery) }
  let(:policy) { ShippingPolicy.new(current_user, record) }
  let(:policy_with_class) { ShippingPolicy.new(current_user, Route) }

  context "when you are an admin" do
    let(:current_user) { build_stubbed(:user, :as_admin, bakery: bakery) }
    it "has access to shipping routes" do
      expect(policy_with_class).to authorize(:index)
      expect(policy_with_class).to authorize(:new)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it "does not have access to shipping routes from other bakeries" do
      current_user.bakery = build_stubbed(:bakery)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it "does not have access to shipping routes if you have no bakery" do
      current_user.bakery = nil
      expect(policy_with_class).to_not authorize(:index)
      expect(policy_with_class).to_not authorize(:new)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    describe "scope" do
      let(:bakery) { create(:bakery) }
      let(:current_user) { create(:user, :as_admin, bakery: bakery) }
      let(:record) { create(:route, bakery: bakery) }
      it "returns no shipping routes if you do not have a bakery" do
        current_user.bakery = nil
        expect(policy.scope).to be_empty
      end

      it "returns only shipping routes from your bakery" do
        create(:route)
        expect(policy.scope).to contain_exactly(record)
      end
    end
  end

  context "when shipping route access level of none" do
    let(:current_user) { build_stubbed(:user, bakery: bakery, shipping_permission: "none") }
    it "doesn't allow access to shipping routes" do
      expect(policy_with_class).to_not authorize(:index)
      expect(policy_with_class).to_not authorize(:new)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    describe "scope" do
      it "returns no shipping routes" do
        bakery = create(:bakery)
        current_user = create(:user, bakery: bakery, shipping_permission: "none")
        record = create(:route, bakery: bakery)
        create(:route, bakery: bakery)
        policy = ShippingPolicy.new(current_user, record)
        expect(policy.scope).to be_empty
      end
    end
  end

  context "when shipping route access level of read" do
    let(:current_user) { build_stubbed(:user, bakery: bakery, shipping_permission: "read") }
    it "has access to shipping routes" do
      expect(policy).to authorize(:index)
      expect(policy).to authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:new)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    describe "scope" do
      it "returns all shipping routes" do
        bakery = create(:bakery)
        current_user = create(:user, bakery: bakery, shipping_permission: "read")
        record = create(:route, bakery: bakery)
        record_2 = create(:route, bakery: bakery)
        create(:route)
        policy = ShippingPolicy.new(current_user, record)
        expect(policy.scope).to contain_exactly(record, record_2)
      end
    end
  end

  context "when shipping route access level of manage" do
    let(:bakery) { create(:bakery) }
    let(:current_user) { create(:user, bakery: bakery, user_permission: "none", shipping_permission: "manage") }
    let(:record) { create(:route, bakery: bakery) }
    let(:user_policy) { UserPolicy.new(current_user, record) }

    it "has access to users" do
      expect(policy).to authorize(:index)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:new)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    describe "scope" do
      it "returns all shipping routes" do
        record_2 = create(:route, bakery: bakery)
        create(:route)
        policy = ShippingPolicy.new(current_user, record)
        expect(policy.scope).to contain_exactly(record, record_2)
      end
    end
  end
end
