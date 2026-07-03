# frozen_string_literal: true

# Computes the four Bake List sections for a bakery and bake_date, reading
# live order data directly -- never ProductionRun/RunItem, which the client
# explicitly asked to keep untouched.
#
# Retail vs. wholesale is decided by the order's Client#bake_channel, not by
# the numeric value of bake_lead_days -- a client's channel and how many
# days ahead its items bake are independent facts (a wholesale client isn't
# guaranteed to always be exactly 1 day ahead). bake_lead_days_for(product,
# client) is only used to find which delivery date's orders bake on this
# bake_date, scanned across MAX_LEAD_DAYS rather than assumed to be 0 or 1,
# so a product with an unexpected lead time still surfaces instead of
# silently vanishing from every sheet.
class BakeListData
  MAX_LEAD_DAYS = 7

  def initialize(bakery, bake_date)
    @bakery = bakery
    @bake_date = bake_date.to_date
  end

  def retail_items
    @_retail_items ||= items_for(channel: "retail")
  end

  def wholesale_items
    @_wholesale_items ||= items_for(channel: "wholesale")
  end

  def pull_list_items
    @_pull_list_items ||= begin
      products = Product.where(bakery: @bakery, on_pull_list: true, removed: false).order_by_name
      products.map do |product|
        quantity = pull_list_order_items[product].to_a.sum { |item| item.quantity(@bake_date) }
        { product: product, quantity: quantity, trays: product.trays_for(quantity) }
      end
    end
  end

  def viennoiserie_pick_items
    (retail_items + wholesale_items).select { |row| row[:product].vienoisserie? }
  end

  private

  def items_for(channel:)
    bake_date_rows.select { |row| row[:client].bake_channel == channel }
      .group_by { |row| row[:item].product }
      .map do |product, rows|
        quantity = rows.sum { |row| row[:item].quantity(row[:delivery_date]) }
        { product: product, quantity: quantity, trays: product.trays_for(quantity) }
      end
      .sort_by { |row| row[:product].name }
  end

  def bake_date_rows
    @_bake_date_rows ||= (0..MAX_LEAD_DAYS).flat_map do |lead|
      delivery_date = @bake_date + lead.days
      Order.active(delivery_date).where(bakery: @bakery).includes(:client, order_items: :product).flat_map do |order|
        order.order_items
          .select { |item| item.product.bake_lead_days_for(order.client) == lead }
          .map { |item| { item: item, client: order.client, delivery_date: delivery_date } }
      end
    end
  end

  # Pull/prep items aren't baked fresh (no bake_lead_days to derive a
  # delivery date from), so their quantity is read for the bake_date itself
  # -- matching retail's "pulled fresh that morning" cadence.
  def pull_list_order_items
    @_pull_list_order_items ||= Order.active(@bake_date).where(bakery: @bakery).includes(order_items: :product)
      .flat_map(&:order_items)
      .group_by(&:product)
  end
end
