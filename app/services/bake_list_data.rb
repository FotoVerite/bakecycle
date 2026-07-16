# frozen_string_literal: true

# Computes the Bake List sections for a bakery and bake_date, reading live
# order data directly -- never ProductionRun/RunItem, which the client
# explicitly asked to keep untouched.
class BakeListData
  RETAIL_LEAD_DAYS = 0
  WHOLESALE_LEAD_DAYS = 1
  BAKE_LEAD_DAYS = [RETAIL_LEAD_DAYS, WHOLESALE_LEAD_DAYS].freeze
  PRODUCT_TYPE_LABELS = {
    "vienoisserie" => "Viennoiserie",
    "tart_and_desert" => "Tart And Dessert",
    "other" => "Pound Cake"
  }.freeze
  # Bread, Cookie, and Viennoiserie get their own Retail/Wholesale bread
  # sheets; everything else (Quiche, Sandwich, Tart & Dessert, Pound Cake...)
  # is grouped onto a single combined sheet instead -- see #other_sections.
  BREAD_SHEET_PRODUCT_TYPES = %w[bread cookie vienoisserie].freeze

  # All Roulé flavors share one untopped base pastry; on the Vienn Pick they
  # collapse into a single "Roule" pick row (the plain base staff tray up),
  # with the per-topping split living on the Retail/Wholesale Bake sheets
  # instead. Deliberately anchored to the "Roule, <topping>" naming only --
  # legacy "<flavor> Roule" names are treated as distinct products (confirmed
  # with the client).
  ROULE_NAME_PATTERN = /\Aroule\b/i
  ROULE_ROW_NAME = "Roule"

  # Pate Fermentee is a standing daily pre-ferment, not an order-driven item:
  # the client tray-up is a fixed 8 trays every day in perpetuity. It has no
  # Product record, so it's injected as a synthetic Vienn Pick row.
  PATE_FERMENTEE_NAME = "Pate Fermentee"
  PATE_FERMENTEE_TRAYS = 8

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
    @_retail_sections ||= sections_for(retail_items.select { |row| bread_sheet_type?(row) })
  end

  def wholesale_sections
    @_wholesale_sections ||= sections_for(wholesale_items.select { |row| bread_sheet_type?(row) })
  end

  # The Pull Prep list uses products explicitly marked for pull/prep, while
  # following the same delivery-date/lead-time schedule as the bake sheets:
  # lead-0 items are for the selected date and lead-1 items are for tomorrow.
  def pull_prep_sections
    @_pull_prep_sections ||= begin
      grouped = pull_prep_rows.group_by { |row| row[:product].product_type }
      sorted = grouped.sort_by { |product_type, _rows| Product.product_types.fetch(product_type) }
      sorted.map do |product_type, rows|
        {
          name: PRODUCT_TYPE_LABELS.fetch(product_type, product_type.titleize),
          product_type: product_type,
          rows: rows.sort_by { |row| row[:product].name }
        }
      end
    end
  end

  # The Vienn Pick lists *every* active Viennoiserie product, showing zero when
  # there are no orders that day (unlike the bake sheets, which only list what's
  # actually ordered) -- the pick sheet doubles as a standing checklist. The
  # Roulé family collapses into one "Roule" row, and Pate Fermentee is appended
  # as a fixed synthetic prep row. Rows carry name/pieces_per_tray directly
  # rather than a Product, so the synthetic rows fit the same shape.
  def viennoiserie_pick_items
    @_viennoiserie_pick_items ||= begin
      retail_by_product = viennoiserie_quantities(retail_items)
      wholesale_by_product = viennoiserie_quantities(wholesale_items)

      products = Product.vienoisserie
        .where(bakery: @bakery, removed: false, inactive: false, on_pull_list: false)
        .order_by_name
      roule_products, single_products = products.partition { |product| roule_product?(product) }

      rows = single_products.map do |product|
        vienn_pick_row(
          name: product.name,
          pieces_per_tray: product.pieces_per_tray,
          retail_quantity: retail_by_product[product].to_i,
          wholesale_quantity: wholesale_by_product[product].to_i
        )
      end
      rows << collapsed_roule_row(roule_products, retail_by_product, wholesale_by_product) if roule_products.any?
      rows = rows.sort_by { |row| row[:name] }
      # Pate Fermentee is a fixed daily prep, not a picked item -- pin it last,
      # separate from the order-driven rows.
      rows << pate_fermentee_row
      rows
    end
  end

  def roule_product?(product)
    product.name.match?(ROULE_NAME_PATTERN)
  end

  # The retail-lead quantity for a product that also has a wholesale bake --
  # used to fold retail volume into the Wholesale sheet's overbake percentage
  # base (the actual bake batch size for an item split across both sheets is
  # retail + wholesale combined, so the overbake margin should be sized
  # against that combined total, not the wholesale slice alone). Zero when
  # the product has no retail-lead orders that day.
  def retail_quantity_for(product)
    @_retail_quantity_by_product ||= retail_items.each_with_object({}) do |row, memo|
      memo[row[:product]] = row[:quantity]
    end
    @_retail_quantity_by_product[product].to_i
  end

  private

  def viennoiserie_quantities(items)
    items.each_with_object({}) do |row, memo|
      memo[row[:product]] = row[:quantity] if row[:product].vienoisserie?
    end
  end

  def vienn_pick_row(name:, pieces_per_tray:, retail_quantity:, wholesale_quantity:)
    {
      name: name,
      pieces_per_tray: pieces_per_tray,
      retail_quantity: retail_quantity,
      wholesale_quantity: wholesale_quantity,
      quantity: retail_quantity + wholesale_quantity
    }
  end

  def collapsed_roule_row(roule_products, retail_by_product, wholesale_by_product)
    vienn_pick_row(
      name: ROULE_ROW_NAME,
      # One shared base pastry -- use the family's tray count (they should agree;
      # take the first present when sorted by name for a stable choice).
      pieces_per_tray: roule_products.map(&:pieces_per_tray).compact.first,
      retail_quantity: roule_products.sum { |product| retail_by_product[product].to_i },
      wholesale_quantity: roule_products.sum { |product| wholesale_by_product[product].to_i }
    )
  end

  def pate_fermentee_row
    {
      name: PATE_FERMENTEE_NAME,
      pieces_per_tray: nil,
      retail_quantity: 0,
      wholesale_quantity: 0,
      quantity: 0,
      fixed_trays: PATE_FERMENTEE_TRAYS
    }
  end

  def pull_prep_rows
    @_pull_prep_rows ||= begin
      items_by_product = pull_prep_date_rows.group_by { |row| row[:item].product }
      rows = items_by_product.filter_map do |product, date_rows|
        quantity = date_rows.sum { |row| row[:item].quantity(row[:delivery_date]) }
        next unless quantity.positive?

        client_quantities = date_rows.group_by { |row| row[:client] }
          .transform_values do |client_rows|
            client_rows.sum { |row| row[:item].quantity(row[:delivery_date]) }
          end
        { product: product, quantity: quantity, client_quantities: client_quantities }
      end
      rows.sort_by { |row| row[:product].name }
    end
  end

  def bread_sheet_type?(row)
    BREAD_SHEET_PRODUCT_TYPES.include?(row[:product].product_type)
  end

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

  def pull_prep_date_rows
    @_pull_prep_date_rows ||= BAKE_LEAD_DAYS.flat_map do |lead|
      delivery_date = @bake_date + lead.days
      Order.active(delivery_date).where(bakery: @bakery).includes(:client, order_items: :product).flat_map do |order|
        order.order_items
          .select { |item| pull_prep_product?(item.product) }
          .select { |item| item.product.bake_lead_days_for(order.client) == lead }
          .map { |item| { item: item, client: order.client, delivery_date: delivery_date, lead_days: lead } }
      end
    end
  end

  def pull_prep_product?(product)
    product.present? && !product.removed? && !product.inactive? && product.on_pull_list?
  end
end
