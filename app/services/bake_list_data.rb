# frozen_string_literal: true

# Computes the Bake List sections for a bakery and bake_date, reading from
# Shipment/ShipmentItem -- shipments are the source of truth for a given day
# (orders are the standing template; shipments and production runs get
# corrected directly, often without the order being updated to match), so
# this stays consistent with Daily Totals and the Production Run report,
# which are both Shipment-derived.
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

  # Same idea as Roulé, mirrored the other direction: the croissant family is
  # named "<filling> Croissant" (Almond Croissant, Chocolate Croissant, Ham &
  # Brie Croissant...) rather than "Croissant, <filling>", so the pattern
  # anchors on the end of the name instead of the start. Collapses into one
  # "Croissant" pick row; per-variant detail still lives on the Retail/
  # Wholesale Bake sheets. Optional trailing "s" covers "Croissants for Almond
  # Croissants" -- the plain base pastry used to assemble almond croissants,
  # same relationship as Roule's untopped base.
  CROISSANT_NAME_PATTERN = /\bcroissants?\z/i
  CROISSANT_ROW_NAME = "Croissant"

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

  # The Vienn Pick lists every active product flagged Product#on_vienn_pick
  # that has orders that day -- items with nothing ordered (zero retail and
  # zero wholesale) are left off rather than shown as a zero row. Membership
  # is an explicit per-product flag (set on the product form, next to Pull
  # Prep), not inferred from product_type -- a product doesn't have to be
  # Viennoiserie to show up here. The Roulé and Croissant families each
  # collapse into one row ("Roule", "Croissant"), and Pate Fermentee is
  # appended as a fixed synthetic prep row regardless of the order-driven
  # rows, since it's a standing daily prep, not tied to orders. Rows carry
  # name/pieces_per_tray directly rather than a Product, so the synthetic
  # rows fit the same shape.
  def viennoiserie_pick_items
    @_viennoiserie_pick_items ||= begin
      retail_rows_by_product = viennoiserie_rows(retail_items)
      wholesale_rows_by_product = viennoiserie_rows(wholesale_items)

      products = Product
        .where(bakery: @bakery, removed: false, inactive: false, on_vienn_pick: true)
        .order_by_name
      roule_products, remaining = products.partition { |product| roule_product?(product) }
      croissant_products, single_products = remaining.partition { |product| croissant_product?(product) }

      rows = single_products.map do |product|
        vienn_pick_row(
          name: product.name,
          pieces_per_tray: product.pieces_per_tray,
          retail_quantity: quantity_with_overbake(product, retail_rows_by_product[product]),
          wholesale_quantity: quantity_with_overbake(product, wholesale_rows_by_product[product])
        )
      end
      if roule_products.any?
        rows << collapsed_family_row(ROULE_ROW_NAME, roule_products, retail_rows_by_product, wholesale_rows_by_product)
      end
      if croissant_products.any?
        rows << collapsed_family_row(CROISSANT_ROW_NAME, croissant_products, retail_rows_by_product, wholesale_rows_by_product)
      end
      rows = rows.select { |row| row[:quantity].positive? }.sort_by { |row| row[:name] }
      # Pate Fermentee is a fixed daily prep, not a picked item -- pin it last,
      # separate from the order-driven rows, and unaffected by the zero filter.
      rows << pate_fermentee_row
      rows
    end
  end

  def roule_product?(product)
    product.name.match?(ROULE_NAME_PATTERN)
  end

  def croissant_product?(product)
    product.name.match?(CROISSANT_NAME_PATTERN)
  end

  # Overbake here must match Production Run / Daily Totals exactly for the
  # same items, since staff rely on it to know how much spare stock genuinely
  # exists (to patch a mistake, or pull for samples/tests) -- a second,
  # independently-computed number is worse than useless if it can disagree.
  # bake_lead_days is only used (via #items_for) to select *which* shipment
  # items belong on this sheet; it does not stand in for the item's own
  # production-run identity. Once those items have been picked up by kickoff
  # (ShipmentItem#production_run_id set), the authoritative overbake for them
  # already exists on RunItem -- read it from there instead of recomputing.
  # Only fall back to estimating from order quantity when kickoff hasn't
  # reached these items yet, so the sheet still shows a number instead of
  # going blank.
  #
  # Retail and wholesale are each sized off their own quantity alone, not a
  # combined total -- a retail-lead and wholesale-lead order for the same
  # product are never the same physical batch (production_start is
  # delivery_date - total_lead_days, and the two lead buckets' delivery
  # dates are always a day apart), so retail overbake isn't a slice of
  # wholesale's margin -- it's its own margin against its own quantity, same
  # as wholesale's.
  def quantity_with_overbake(product, row)
    quantity = row ? row[:quantity] : 0
    authoritative_overbake = run_item_overbake(product, row&.dig(:shipment_items))
    return quantity + authoritative_overbake if authoritative_overbake

    quantity + (quantity * product.over_bake / 100).ceil
  end

  # Returns the summed RunItem#overbake_quantity across every production run
  # these shipment items have already been assigned to, or nil if any of them
  # haven't been picked up by kickoff yet (no production_run_id set) -- nil
  # signals "not available yet," distinct from a real zero.
  def run_item_overbake(product, shipment_items)
    return nil if shipment_items.blank?

    run_ids = shipment_items.map(&:production_run_id)
    return nil if run_ids.any?(&:nil?)

    RunItem.where(production_run_id: run_ids.uniq, product_id: product.id).sum(:overbake_quantity)
  end

  private

  def viennoiserie_rows(items)
    items.each_with_object({}) do |row, memo|
      memo[row[:product]] = row if row[:product].on_vienn_pick?
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

  def collapsed_family_row(name, products, retail_rows_by_product, wholesale_rows_by_product)
    vienn_pick_row(
      name: name,
      # One shared base pastry -- use the family's tray count (they should agree;
      # take the first present when sorted by name for a stable choice).
      pieces_per_tray: products.map(&:pieces_per_tray).compact.first,
      # Each variant's own overbake is computed (and rounded) before summing
      # into the collapsed row, not derived from the family's combined total
      # -- variants can have different over_bake percentages.
      retail_quantity: products.sum { |product| quantity_with_overbake(product, retail_rows_by_product[product]) },
      wholesale_quantity: products.sum { |product| quantity_with_overbake(product, wholesale_rows_by_product[product]) }
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
        quantity = date_rows.sum { |row| row[:item].product_quantity }
        next unless quantity.positive?

        client_quantities = date_rows.group_by { |row| row[:client] }
          .transform_values do |client_rows|
            client_rows.sum { |row| row[:item].product_quantity }
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
        quantity = rows.sum { |row| row[:item].product_quantity }
        next unless quantity.positive?

        client_quantities = rows.group_by { |row| row[:client] }.transform_values do |client_rows|
          client_rows.sum { |row| row[:item].product_quantity }
        end

        {
          product: product,
          quantity: quantity,
          trays: product.trays_for(quantity),
          lead_days: lead_days,
          client_quantities: client_quantities,
          shipment_items: rows.map { |row| row[:item] }
        }
      end
    rows.compact.sort_by { |row| row[:product].name }
  end

  def bake_date_rows
    @_bake_date_rows ||= BAKE_LEAD_DAYS.flat_map do |lead|
      delivery_date = @bake_date + lead.days
      Shipment.where(bakery: @bakery, date: delivery_date)
        .includes(:client, shipment_items: :product).flat_map do |shipment|
        shipment.shipment_items
          .select { |item| bake_list_product?(item.product) }
          .select { |item| item.product.bake_lead_days_for(shipment.client) == lead }
          .map { |item| { item: item, client: shipment.client, delivery_date: delivery_date, lead_days: lead } }
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
      Shipment.where(bakery: @bakery, date: delivery_date)
        .includes(:client, shipment_items: :product).flat_map do |shipment|
        shipment.shipment_items
          .select { |item| pull_prep_product?(item.product) }
          .select { |item| item.product.bake_lead_days_for(shipment.client) == lead }
          .map { |item| { item: item, client: shipment.client, delivery_date: delivery_date, lead_days: lead } }
      end
    end
  end

  def pull_prep_product?(product)
    product.present? && !product.removed? && !product.inactive? && product.on_pull_list?
  end
end
