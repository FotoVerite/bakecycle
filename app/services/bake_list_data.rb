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

  # Unlike Roulé, the "<filling> Croissant" products (Almond Croissant,
  # Chocolate Croissant, Mini Croissant...) are genuinely different items with
  # different tray sizes (confirmed with the client) -- they stay separate
  # pick rows, not folded together. The exceptions are base-pastry products
  # like "Croissants for Almond Croissants": the same plain croissant dough
  # as the base "Croissant" row, just earmarked for a different use rather
  # than a genuinely distinct product, so its count folds into Croissant's
  # (using Croissant's own tray size). A list, not a single name, since more
  # of these base-pastry variants can exist beyond the almond one.
  CROISSANT_ROW_NAME = "Croissant"
  CROISSANT_EXTRA_NAMES = [
    "Croissants for Almond Croissants"
  ].freeze

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
    @_wholesale_sections ||= sections_for(wholesale_bread_sheet_rows)
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
  # Viennoiserie to show up here. Roulé collapses into one "Roule" row (one
  # shared base pastry, confirmed with the client); Croissant variants stay
  # separate rows (different items, different tray sizes) except for
  # "Croissants for Almond Croissants," which folds into the base "Croissant"
  # row's count. Pate Fermentee is appended as a fixed synthetic prep row
  # regardless of the order-driven rows, since it's a standing daily prep, not
  # tied to orders. Rows carry name/pieces_per_tray directly rather than a
  # Product, so the synthetic rows fit the same shape.
  def viennoiserie_pick_items
    @_viennoiserie_pick_items ||= begin
      retail_rows_by_product = viennoiserie_rows(retail_items)
      wholesale_rows_by_product = viennoiserie_rows(wholesale_items)

      products = Product
        .where(bakery: @bakery, removed: false, inactive: false, on_vienn_pick: true)
        .order_by_name
      roule_products, remaining = products.partition { |product| roule_product?(product) }
      extra_croissant_products, single_products = remaining.partition { |product| croissant_extra_product?(product) }

      rows = single_products.map do |product|
        vienn_pick_row(
          name: product.name,
          pieces_per_tray: product.pieces_per_tray,
          retail_quantity: retail_bake_total(product, retail_rows_by_product[product]),
          wholesale_quantity: wholesale_bake_total(product, wholesale_rows_by_product[product])
        )
      end
      if roule_products.any?
        rows << collapsed_family_row(ROULE_ROW_NAME, roule_products, retail_rows_by_product, wholesale_rows_by_product)
      end
      fold_croissant_extras_into_base_row(rows, extra_croissant_products, retail_rows_by_product,
                                          wholesale_rows_by_product)
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

  def croissant_extra_product?(product)
    name = product.name.strip
    CROISSANT_EXTRA_NAMES.any? { |extra_name| name.casecmp?(extra_name) }
  end

  # Retail bake = order exactly. Retail is baked to order with no overbake
  # buffer of its own; the whole day's overbake is carried by the wholesale
  # bake instead (confirmed with the client -- the Retail Bread sheet shows
  # order-only totals, the Wholesale Bread sheet carries the overbake).
  def retail_bake_total(_product, retail_row)
    retail_row ? retail_row[:quantity] : 0
  end

  # Wholesale bake = its own order quantity plus the entire day's overbake for
  # this product. Since retail carries none, all of the overbake lands here.
  def wholesale_bake_total(product, wholesale_row)
    wholesale_quantity = wholesale_row ? wholesale_row[:quantity] : 0
    wholesale_quantity + day_overbake(product, wholesale_row)
  end

  private

  # Wholesale carries the whole day's overbake for every bread-sheet product
  # (see #wholesale_bake_total), so a product with retail orders but zero
  # wholesale orders that day still needs a row on the Wholesale Bread sheet
  # -- otherwise its overbake silently disappears from Wholesale even though
  # Vienn Pick (which walks every active on_vienn_pick product rather than
  # only ones with an existing wholesale row) keeps showing it. Only
  # injected when there's real overbake to show, mirroring the zero-row
  # omission used elsewhere (retail_items, viennoiserie_pick_items).
  def wholesale_bread_sheet_rows
    existing = wholesale_items.select { |row| bread_sheet_type?(row) }
    covered_products = existing.map { |row| row[:product] }.to_set
    overbake_only = retail_items
      .select { |row| bread_sheet_type?(row) && !covered_products.include?(row[:product]) }
      .filter_map { |row| overbake_only_wholesale_row(row[:product]) }
    (existing + overbake_only).sort_by { |row| row[:product].name }
  end

  def overbake_only_wholesale_row(product)
    row = { quantity: 0, shipment_items: [] }
    return unless day_overbake(product, row).positive?

    row.merge(product: product, trays: product.trays_for(0), lead_days: WHOLESALE_LEAD_DAYS, client_quantities: {})
  end

  # The overbake for a product on this bake day, all of which goes to the
  # wholesale bake. It must match Production Run / Daily Totals exactly, since
  # staff rely on it to know how much spare stock genuinely exists (to patch a
  # mistake, or pull for samples/tests) -- a second, independently-computed
  # number is worse than useless if it can disagree.
  #
  # Overbake is a whole-day figure: Production Run/Daily Totals size it against
  # the grand total (all invoices for the day) and store it on RunItem. Once
  # kickoff has built that run, read RunItem#overbake_quantity for the
  # wholesale delivery's run(s) directly, so all three documents agree by
  # construction (this is where the client's 11 comes from -- the real run's
  # ceil(order * over_bake%), not a re-derivation off the bake list's own
  # subtotal). Before kickoff (future dates, no run yet), fall back to the
  # same formula the quantifier uses, sized on the retail + wholesale grand
  # total so it still reflects the whole day, not the wholesale slice alone.
  def day_overbake(product, wholesale_row)
    shipment_items = wholesale_row&.dig(:shipment_items)
    run_overbake = run_item_overbake(product, shipment_items)
    return run_overbake if run_overbake

    # No wholesale shipment items of its own to derive a production_run_id
    # from (a retail-only product's synthetic overbake row) -- fall back to
    # looking the run up directly by (bakery, bake_date) instead. This is
    # only a fallback, never overriding the shipment_items-based lookup
    # above, since ProductionRunService creates exactly one ProductionRun
    # per bakery/date, so it's unambiguous without needing to assume a
    # retail item's production_start lines up with the wholesale delivery's
    # (it needn't -- they can have different total_lead_days).
    if shipment_items.blank?
      run_overbake = production_run_overbake(product)
      return run_overbake if run_overbake
    end

    grand_total = retail_quantity_for(product) + (wholesale_row ? wholesale_row[:quantity] : 0)
    (grand_total * product.over_bake / 100).ceil
  end

  # Summed RunItem#overbake_quantity across the production run(s) these
  # shipment items belong to, or nil when kickoff hasn't built them yet (no
  # production_run_id) so there is no authoritative number to defer to.
  def run_item_overbake(product, shipment_items)
    return nil if shipment_items.blank?

    run_ids = shipment_items.map(&:production_run_id)
    return nil if run_ids.any?(&:nil?)

    RunItem.where(production_run_id: run_ids.uniq, product_id: product.id).sum(:overbake_quantity)
  end

  def production_run_overbake(product)
    run = ProductionRun.find_by(bakery: @bakery, date: @bake_date)
    return nil unless run

    RunItem.find_by(production_run: run, product: product)&.overbake_quantity
  end

  # This product's raw retail order quantity for the day (no overbake), used
  # only to size the pre-kickoff grand-total overbake fallback. Zero when the
  # product has no retail-lead orders that day.
  def retail_quantity_for(product)
    @_retail_quantity_by_product ||= retail_items.each_with_object({}) do |row, memo|
      memo[row[:product]] = row[:quantity]
    end
    @_retail_quantity_by_product[product].to_i
  end

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
      # Each variant's retail (order-only) and wholesale (order + its own
      # overbake) totals are summed into the collapsed row -- variants can have
      # different over_bake percentages, so each is figured before summing.
      retail_quantity: products.sum { |product| retail_bake_total(product, retail_rows_by_product[product]) },
      wholesale_quantity: products.sum { |product| wholesale_bake_total(product, wholesale_rows_by_product[product]) }
    )
  end

  # Adds "Croissants for Almond Croissants"' own quantity into the base
  # "Croissant" row's count, in place -- keeping Croissant's own tray size
  # rather than the extra product's, since it's the same base pastry. If
  # there's no base Croissant row that day (no plain Croissant orders, or the
  # product isn't flagged on_vienn_pick), the extra product still needs to be
  # counted somewhere, so it falls back to its own row instead of silently
  # dropping real order quantity.
  def fold_croissant_extras_into_base_row(rows, extra_products, retail_rows_by_product, wholesale_rows_by_product)
    return if extra_products.empty?

    extra_retail = extra_products.sum { |product| retail_bake_total(product, retail_rows_by_product[product]) }
    extra_wholesale = extra_products.sum { |product|
      wholesale_bake_total(product, wholesale_rows_by_product[product])
    }
    base_row = rows.find { |row| row[:name].strip.casecmp?(CROISSANT_ROW_NAME) }

    if base_row
      base_row[:retail_quantity] += extra_retail
      base_row[:wholesale_quantity] += extra_wholesale
      base_row[:quantity] += extra_retail + extra_wholesale
    else
      rows << vienn_pick_row(
        name: extra_products.first.name,
        pieces_per_tray: extra_products.map(&:pieces_per_tray).compact.first,
        retail_quantity: extra_retail,
        wholesale_quantity: extra_wholesale
      )
    end
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
    @_bake_date_rows ||= date_rows_matching { |product| bake_list_product?(product) }
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
    @_pull_prep_date_rows ||= date_rows_matching { |product| pull_prep_product?(product) }
  end

  def pull_prep_product?(product)
    product.present? && !product.removed? && !product.inactive? && product.on_pull_list?
  end

  # Shared by #bake_date_rows and #pull_prep_date_rows -- both walk the same
  # lead-day/delivery-date schedule and shipment includes, differing only in
  # which items they keep.
  def date_rows_matching(&product_filter)
    BAKE_LEAD_DAYS.flat_map do |lead|
      delivery_date = @bake_date + lead.days
      Shipment.where(bakery: @bakery, date: delivery_date)
        .includes(:client, shipment_items: :product).flat_map do |shipment|
        shipment.shipment_items
          .select { |item| product_filter.call(item.product) }
          .select { |item| item.product.bake_lead_days_for(shipment.client) == lead }
          .map { |item| { item: item, client: shipment.client, delivery_date: delivery_date, lead_days: lead } }
      end
    end
  end
end
