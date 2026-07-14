# frozen_string_literal: true

class BackfillCancellationOverrideForZeroQuantityTempOrders < ActiveRecord::Migration[8.1]
  # Before cancellation_override existed (prior migration), a cancellation was
  # encoded purely as a single-day temporary order with every item's quantity
  # zeroed out for that day -- the same shape OrderCancellationService#zero_order?
  # still detects. This makes the flag agree with that pre-existing data so it
  # can become the single source of truth going forward, instead of two
  # mechanisms answering "is this cancelled?" differently depending on when
  # the row was created.
  def up
    Order.where(order_type: "temporary", cancellation_override: false)
      .includes(:order_items)
      .find_each do |order|
        items = order.order_items
        next unless items.any? && items.all? { |item| item.quantity(order.start_date).zero? }

        order.update_column(:cancellation_override, true)
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
