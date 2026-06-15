# frozen_string_literal: true

require "rails_helper"

RSpec.describe PinnedActionRegistry do
  let(:context) { Rails.application.routes.url_helpers }

  it "only exposes actions the user can access" do
    user = build(:user, client_permission: "read", shipping_permission: "none",
                        production_permission: "none", product_permission: "none")

    keys = described_class.available_for(user, context: context).map(&:key)

    expect(keys).to include("clients", "orders", "invoices", "reports")
    expect(keys).not_to include("new_order", "packing_slips", "products")
  end

  it "does not resolve retired or invalid stored keys" do
    user = create(:user)
    pin = UserPinnedAction.new(user: user, action_key: "retired_action", position: 0)

    expect(described_class.entries_for([pin], user: user, context: context)).to be_empty
  end

  it "resolves a registered action to its controlled route" do
    user = create(:user)
    pin = build(:user_pinned_action, user: user, action_key: "new_order")

    entry = described_class.entries_for([pin], user: user, context: context).first

    expect(entry.label).to eq("New Order")
    expect(entry.path).to eq(context.new_order_path)
  end
end
