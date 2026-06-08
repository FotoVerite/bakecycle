# frozen_string_literal: true

require "rails_helper"

describe OrdersHelper, type: :helper do
  describe "#new_order_return_path" do
    it "returns the client path when a client is present" do
      client = Client.new(id: 123)
      assign(:client, client)

      expect(helper.new_order_return_path).to eq(client_path(client))
    end

    it "returns the orders path when no client is present" do
      assign(:client, nil)

      expect(helper.new_order_return_path).to eq(orders_path)
    end
  end
end
