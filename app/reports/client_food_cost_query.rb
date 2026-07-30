# frozen_string_literal: true

# Per-client, per-item breakdown of what was actually invoiced, with food
# cost -- the existing Client Totals report (ClientTotalXlsx) only ever
# summed Shipment#price per client, never touching ShipmentItem/Product, so
# cog-based cost has no home there. This reads the same real-invoice source
# (non-sample Shipment/ShipmentItem) ProductTotalsQuery's invoice source and
# ClientTotalXlsx both already use.
#
# Three drill levels, each its own method rather than one flat table -- a
# per-(client, product, date) grid was the first cut and it was unusable at
# scale (181 clients x every item x every day in range = thousands of rows
# rendered at once). The levels:
#   1. #client_summaries  -- one row per client, whatever's in scope.
#   2. #item_totals        -- one row per item, aggregated across the whole
#      date range. Meaningful once the scope is down to a single client.
#   3. #daily_rows          -- one row per date. Meaningful once the scope is
#      down to a single client AND a single item.
# The caller (controller) decides which level to show based on how narrow
# the client/product filters are -- this class just aggregates at whichever
# grain is asked for.
#
# "Unit Price" is derived as total line revenue / total quantity for the
# group rather than picking one ShipmentItem's product_price, so a
# mid-range price change still nets out to a single consistent number
# instead of an arbitrary pick.
class ClientFoodCostQuery
  DailyRow = Struct.new(
    :date, :quantity, :unit_price, :total_price, :food_cost, :total_food_cost, :food_cost_percent,
    keyword_init: true
  )

  ItemTotal = Struct.new(
    :product, :quantity, :unit_price, :total_price, :food_cost, :total_food_cost, :food_cost_percent,
    keyword_init: true
  )

  ClientSummary = Struct.new(
    :client, :item_count, :quantity, :total_price, :total_food_cost, :food_cost_percent,
    keyword_init: true
  )

  def initialize(bakery, start_date, end_date, client_ids: nil, product_ids: nil)
    @bakery = bakery
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @client_ids = Array(client_ids).reject(&:blank?).presence
    @product_ids = Array(product_ids).reject(&:blank?).presence
  end

  # => [ClientSummary, ...] sorted by client name -- one row per client
  # currently in scope (all invoiced clients, unless narrowed by client_ids)
  def client_summaries
    line_items.group_by { |item| item[:client] }.map do |client, items|
      total_price = items.sum { |i| i[:total_price] }
      total_food_cost = items.sum { |i| i[:total_food_cost] }
      ClientSummary.new(
        client: client,
        item_count: items.map { |i| i[:product] }.uniq.size,
        quantity: items.sum { |i| i[:quantity] },
        total_price: total_price,
        total_food_cost: total_food_cost,
        food_cost_percent: percent(total_food_cost, total_price)
      )
    end.sort_by { |s| s.client.name }
  end

  # => [ItemTotal, ...] sorted by product name -- one row per item, summed
  # across every date in range, for whatever's currently in scope (meant to
  # be called once client_ids narrows scope to a single client)
  def item_totals
    line_items.group_by { |item| item[:product] }.map do |product, items|
      to_item_total(product, items)
    end.sort_by { |t| t.product.name }
  end

  # => [DailyRow, ...] sorted by date -- one row per date, for whatever's
  # currently in scope (meant to be called once client_ids and product_ids
  # both narrow scope to a single client + single item)
  def daily_rows
    line_items.group_by { |item| item[:date] }.map do |date, items|
      to_daily_row(date, items)
    end.sort_by(&:date)
  end

  private

  def line_items
    @line_items ||= build_line_items
  end

  def to_item_total(product, items)
    total_price = items.sum { |i| i[:total_price] }
    quantity = items.sum { |i| i[:quantity] }
    food_cost = product.cog || 0.to_d
    total_food_cost = items.sum { |i| i[:total_food_cost] }
    ItemTotal.new(
      product: product, quantity: quantity,
      unit_price: quantity.positive? ? (total_price / quantity) : 0.to_d,
      total_price: total_price, food_cost: food_cost, total_food_cost: total_food_cost,
      food_cost_percent: percent(total_food_cost, total_price)
    )
  end

  def to_daily_row(date, items)
    total_price = items.sum { |i| i[:total_price] }
    quantity = items.sum { |i| i[:quantity] }
    total_food_cost = items.sum { |i| i[:total_food_cost] }
    DailyRow.new(
      date: date, quantity: quantity,
      unit_price: quantity.positive? ? (total_price / quantity) : 0.to_d,
      total_price: total_price, food_cost: items.first[:product].cog || 0.to_d,
      total_food_cost: total_food_cost, food_cost_percent: percent(total_food_cost, total_price)
    )
  end

  def percent(part, whole)
    whole.positive? ? (part / whole * 100) : 0.to_d
  end

  def build_line_items
    aggregates = aggregate_scope.pluck(
      "shipments.client_id",
      "shipments.date",
      "shipment_items.product_id",
      Arel.sql("SUM(shipment_items.product_quantity)"),
      Arel.sql("SUM(shipment_items.product_price * shipment_items.product_quantity)")
    )
    return [] if aggregates.empty?

    clients = Client.where(id: aggregates.map { |row| row[0] }.uniq).index_by(&:id)
    products = Product.where(id: aggregates.map { |row| row[2] }.uniq).index_by(&:id)

    aggregates.filter_map do |client_id, date, product_id, quantity, total_price|
      next if quantity.to_i <= 0

      client = clients[client_id]
      product = products[product_id]
      next unless client && product

      quantity = quantity.to_i
      total_price = total_price.to_d
      food_cost = product.cog || 0.to_d
      {
        client: client, product: product, date: date, quantity: quantity, total_price: total_price,
        total_food_cost: food_cost * quantity
      }
    end
  end

  def aggregate_scope
    scope = ShipmentItem.joins(:shipment).merge(Shipment.non_sample)
      .where(shipments: { bakery_id: @bakery.id, date: @start_date..@end_date })
    scope = scope.where(shipments: { client_id: @client_ids }) if @client_ids
    scope = scope.where(product_id: @product_ids) if @product_ids
    scope.group("shipments.client_id", "shipments.date", "shipment_items.product_id")
  end
end
