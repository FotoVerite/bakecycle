require "rails_helper"

shared_examples_for "product policy" do |model|
  let(:bakery) { build_stubbed(:bakery) }
  let(:model_name) { model.model_name }
  let(:record) { build_stubbed(model_name, bakery: bakery) }
  let(:policy) { ProductPolicy.new(current_user, record) }
  let(:policy_with_class) { ProductPolicy.new(current_user, model_name) }

  context "when you are an admin" do
    let(:current_user) { build_stubbed(:user, :as_admin, bakery: bakery) }
    it "has access to #{model}s" do
      expect(policy_with_class).to authorize(:index)
      expect(policy_with_class).to authorize(:new)
      expect(policy).to authorize(:show)
      expect(policy).to authorize(:create)
      expect(policy).to authorize(:update)
      expect(policy).to authorize(:edit)
      expect(policy).to authorize(:destroy)
    end

    it "does not have access to #{model}s from other bakeries" do
      current_user.bakery = build_stubbed(:bakery)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    it "does not have access to #{model}s if you have no bakery" do
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
      let(:record) { create(model_name, bakery: bakery) }
      it "returns no #{model}s if you do not have a bakery" do
        current_user.bakery = nil
        expect(policy.scope).to be_empty
      end

      it "returns only #{model}s from your bakery" do
        create(model_name)
        expect(policy.scope).to contain_exactly(record)
      end
    end
  end

  context "when product access level of none" do
    let(:current_user) { build_stubbed(:user, bakery: bakery, product_permission: "none") }
    it "doesn't allow access to #{model}s" do
      expect(policy_with_class).to_not authorize(:index)
      expect(policy_with_class).to_not authorize(:new)
      expect(policy).to_not authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    describe "scope" do
      it "returns no #{model}s" do
        bakery = create(:bakery)
        current_user = create(:user, bakery: bakery, product_permission: "none")
        record = create(model_name, bakery: bakery)
        create(model_name, bakery: bakery)
        policy = ProductPolicy.new(current_user, record)
        expect(policy.scope).to be_empty
      end
    end
  end

  context "when product access level of read" do
    let(:current_user) { build_stubbed(:user, bakery: bakery, product_permission: "read") }
    it "has access to #{model}s" do
      expect(policy).to authorize(:index)
      expect(policy).to authorize(:show)
      expect(policy).to_not authorize(:create)
      expect(policy).to_not authorize(:new)
      expect(policy).to_not authorize(:update)
      expect(policy).to_not authorize(:edit)
      expect(policy).to_not authorize(:destroy)
    end

    describe "scope" do
      it "returns all #{model}s" do
        bakery = create(:bakery)
        current_user = create(:user, bakery: bakery, product_permission: "read")
        record = create(model_name, bakery: bakery)
        record2 = create(model_name, bakery: bakery)
        create(model_name)
        policy = ProductPolicy.new(current_user, record)
        expect(policy.scope).to contain_exactly(record, record2)
      end
    end
  end

  context "when product access level of manage" do
    let(:bakery) { create(:bakery) }
    let(:current_user) { create(:user, bakery: bakery, user_permission: "none", product_permission: "manage") }
    let(:record) { create(model_name, bakery: bakery) }
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
      it "returns all #{model}s" do
        record2 = create(model_name, bakery: bakery)
        create(model_name)
        policy = ProductPolicy.new(current_user, record)
        expect(policy.scope).to contain_exactly(record, record2)
      end
    end
  end
end

describe ProductPolicy do
  model_for_products = [Product, Recipe, Ingredient]

  model_for_products.each do |model|
    context model do
      it_should_behave_like "product policy", model
    end
  end
end
