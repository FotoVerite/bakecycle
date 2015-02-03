require "rails_helper"
require "cancan/matchers"

describe Ability do
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:competitor) { build(:user) }

  describe "managing users" do
    it "allows users to manage users in their bakery" do
      coworker = build(:user, bakery: user.bakery)
      no_bakery_user = build(:user, bakery: nil)

      expect(ability).to be_able_to(:manage, coworker)
      expect(ability).to_not be_able_to(:manage, competitor)
      expect(ability).to_not be_able_to(:manage, no_bakery_user)
    end

    it "allows users to manage themselves" do
      expect(ability).to be_able_to(:manage, user)
    end

    context "no bakery" do
      let(:user) { create(:user, bakery: nil) }

      it "can only manage themselves" do
        other_no_bakery_user = build(:user, bakery: nil)
        expect(ability).to be_able_to(:manage, user)
        expect(ability).to_not be_able_to(:manage, competitor)
        expect(ability).to_not be_able_to(:manage, other_no_bakery_user)
      end
    end

    context "admins" do
      let(:user) { create(:user, :as_admin) }
      it "allows admins to manage all users" do
        no_bakery_user = build(:user, bakery: nil)
        expect(ability).to be_able_to(:manage, user)
        expect(ability).to be_able_to(:manage, competitor)
        expect(ability).to be_able_to(:manage, no_bakery_user)
      end
    end

    context "collections" do
      let(:user) { create(:user) }
      let(:competitor) { create(:user) }

      it "allows users to see users in their bakery" do
        coworkers = create_list(:user, 2, bakery: user.bakery)
        expect(User.accessible_by(ability)).to contain_exactly(*coworkers, user)
        expect(User.accessible_by(ability)).to_not include(competitor)
      end

      it "shows no users if there is no bakery" do
        no_bakery_user = build(:user, bakery: nil)
        create(:user)
        ability_2 = Ability.new(no_bakery_user)
        expect(User.accessible_by(ability_2)).to be_empty
      end

      context "admins" do
        let(:user) { create(:user, :as_admin) }
        it "allows admins to see all users" do
          expect(User.accessible_by(ability)).to contain_exactly(user, competitor)
        end
      end
    end
  end
end
