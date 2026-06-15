# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pinned actions", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it "shows the management screen" do
    get pinned_actions_path

    expect(response).to be_successful
    expect(response.body).to include("Manage Pinned Actions")
  end

  it "renders available pins in both the sidebar and dashboard" do
    create(:user_pinned_action, user: user, action_key: "reports")

    get dashboard_path

    document = Nokogiri::HTML(response.body)
    expect(document.css(".nav-pins a").map(&:text).join).to include("Reports")
    expect(document.css(".dashboard-pinned-actions a").map(&:text).join).to include("Reports")
  end

  it "keeps only the active destination group expanded" do
    get orders_path

    document = Nokogiri::HTML(response.body)
    open_groups = document.css("details.nav-group[open] summary span").map { |node| node.text.strip }
    expect(open_groups).to eq(["Clients"])
  end

  it "ignores retired action keys when rendering navigation" do
    UserPinnedAction.insert_all!([
                                   {
                                     user_id: user.id,
                                     action_key: "retired_action",
                                     position: 0,
                                     created_at: Time.current,
                                     updated_at: Time.current
                                   }
                                 ])

    get dashboard_path

    expect(response).to be_successful
    expect(response.body).not_to include("retired_action")
  end

  it "pins an available action" do
    expect do
      post pinned_actions_path, params: { action_key: "new_order" }
    end.to change(user.user_pinned_actions, :count).by(1)

    expect(response).to redirect_to(pinned_actions_path)
    expect(user.user_pinned_actions.last.action_key).to eq("new_order")
  end

  it "rejects an action the user cannot access" do
    user.update!(production_permission: "none")

    expect do
      post pinned_actions_path, params: { action_key: "daily_recipes" }
    end.not_to change(user.user_pinned_actions, :count)

    expect(flash[:alert]).to eq("That action is not available to pin.")
  end

  it "prevents a sixth pin" do
    PinnedActionRegistry.keys.first(5).each_with_index do |action_key, position|
      create(:user_pinned_action, user: user, action_key: action_key, position: position)
    end

    post pinned_actions_path, params: { action_key: PinnedActionRegistry.keys.fetch(5) }

    expect(user.user_pinned_actions.count).to eq(5)
    expect(flash[:alert]).to include("You can pin up to 5 actions")
  end

  it "unpins one of the current user's actions" do
    pin = create(:user_pinned_action, user: user, action_key: "reports")

    expect do
      delete pinned_action_path(pin)
    end.to change(user.user_pinned_actions, :count).by(-1)
  end

  it "reorders pins" do
    first = create(:user_pinned_action, user: user, action_key: "reports", position: 0)
    second = create(:user_pinned_action, user: user, action_key: "orders", position: 1)

    patch reorder_pinned_actions_path, params: { ordered_ids: [second.id, first.id] }

    expect(user.user_pinned_actions.ordered).to eq([second, first])
  end

  it "does not allow one user to remove another user's pin" do
    other_pin = create(:user_pinned_action, action_key: "reports")

    expect do
      delete pinned_action_path(other_pin)
    end.not_to change(UserPinnedAction, :count)
  end
end
