# frozen_string_literal: true

# Computes the Bake List sections for a bakery and bake_date, reading live
# order data directly -- never ProductionRun/RunItem, which the client
# explicitly asked to keep untouched.
class BakeListData
  RETAIL_LEAD_DAYS = 0
  WHOLESALE_LEAD_DAYS = 1
  BAKE_LEAD_DAYS = [RETAIL_LEAD_DAYS, WHOLESALE_LEAD_DAYS].freeze
  PRODUCT_TYPE_LABELS = {
    "vienoisserie" => "Viennoiserie"
  }.freeze

  def initialize(bakery, bake_date)
    @bakery = bakery
    @bake_date = bake_date.to_date
  end

  def retail_items
    @_retail_items ||= items_for(lead_days: RETAIL_LEAD_DAYS)
  end

  def wholesale_items
    @_wholesale_items ||= items_for(lead_days: WHOLESALE_LEAD_DAYS)
  end

  def retail_sections
    @_retail_sections ||= sections_for(retail_items)
  end

  def wholesale_sections
    @_wholesale_sections ||= sections_for(wholesale_items)
  end

  def retail_clients
    @_retail_clients ||= retail_items.flat_map { |row| row[:client_quantities].keys }.uniq.sort_by(&:name)
  end

  def pull_list_items
    @_pull_list_items ||= begin
      products = Product.where(bakery: @bakery, on_pull_list: true, removed: false).order_by_name
      rows = products.map do |product|
        quantity = pull_list_order_items[product].to_a.sum { |item| item.quantity(@bake_date) }
        { product: product, quantity: quantity, trays: product.trays_for(quantity) }
      end
      rows.select { |row| row[:quantity].positive? }
    end
  end

  def viennoiserie_pick_items
    @_viennoiserie_pick_items ||= begin
      rows_by_product = (retail_items + wholesale_items)
        .select { |row| row[:product].vienoisserie? }
        .group_by { |row| row[:product] }

      rows = rows_by_product.map do |product, rows|
        retail_quantity = rows.find { |row| row[:lead_days] == RETAIL_LEAD_DAYS }&.fetch(:quantity) || 0
        wholesale_quantity = rows.find { |row| row[:lead_days] == WHOLESALE_LEAD_DAYS }&.fetch(:quantity) || 0
        quantity = retail_quantity + wholesale_quantity
        next unless quantity.positive?

        {
          product: product,
          quantity: quantity,
          retail_quantity: retail_quantity,
          wholesale_quantity: wholesale_quantity,
          tray_count: product.pieces_per_tray
        }
      end
      rows.compact.sort_by { |row| row[:product].name }
    end
  end

  private

  def items_for(lead_days:)
    rows = bake_date_rows.select { |row| row[:lead_days] == lead_days }
      .group_by { |row| row[:item].product }
      .map do |product, rows|
        quantity = rows.sum { |row| row[:item].quantity(row[:delivery_date]) }
        next unless quantity.positive?

        client_quantities = rows.group_by { |row| row[:client] }.transform_values do |client_rows|
          client_rows.sum { |row| row[:item].quantity(row[:delivery_date]) }
        end

        {
          product: product,
          quantity: quantity,
          trays: product.trays_for(quantity),
          lead_days: lead_days,
          client_quantities: client_quantities
        }
      end
    rows.compact.sort_by { |row| row[:product].name }
  end

  def bake_date_rows
    @_bake_date_rows ||= BAKE_LEAD_DAYS.flat_map do |lead|
      delivery_date = @bake_date + lead.days
      Order.active(delivery_date).where(bakery: @bakery).includes(:client, order_items: :product).flat_map do |order|
        order.order_items
          .select { |item| bake_list_product?(item.product) }
          .select { |item| item.product.bake_lead_days_for(order.client) == lead }
          .map { |item| { item: item, client: order.client, delivery_date: delivery_date, lead_days: lead } }
      end
    end
  end

  def sections_for(items)
    grouped_items = items.group_by { |row| row[:product].product_type }
    sorted_items = grouped_items.sort_by { |product_type, _rows| Product.product_types.fetch(product_type) }
    sorted_items.map do |product_type, rows|
      {
        name: PRODUCT_TYPE_LABELS.fetch(product_type, product_type.titleize),
        product_type: product_type,
        rows: rows.sort_by { |row| row[:product].name }
      }
    end
  end

  def bake_list_product?(product)
    product.present? && !product.removed? && !product.inactive? && !product.on_pull_list?
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
