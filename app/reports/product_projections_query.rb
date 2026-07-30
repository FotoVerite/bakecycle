# frozen_string_literal: true

# Projects per-date, per-product quantities for the "Product Projections"
# report -- built for clients who order irregularly (no standing order) but
# in a real recurring pattern, e.g. a farmers-market account that shows up
# most Saturdays without ever being told to. Order/OrderItem only stores
# weekday-template quantities for orders that already exist, so it can't
# answer "what would this client probably order" -- ShipmentItem is the
# actual delivered-quantity history, and that's what this class reads.
#
# Three layers, applied in order:
#   1. Baseline -- median of the same weekday's actual quantity over the
#      last 4 occurrences, dropping weeks with no order entirely (a 0 isn't
#      counted as "ordered zero", it's excluded before the median).
#   2. Seasonal adjustment -- this same calendar week last year vs. the week
#      immediately before it, last year, as a percent change per product
#      category (product_type), applied to every SKU in that category. This
#      catches "the week before a holiday always jumps" without needing this
#      year's own history to have caught up to the pattern yet.
#   3. Buffer -- a percent per category, set by hand before generating
#      (defaults to 10% for any category not given explicitly). This is the
#      one number in the whole calculation that's a judgment call, not a
#      statistic -- nothing here tries to derive it.
class ProductProjectionsQuery
  DEFAULT_BUFFER_PERCENT = 10.0
  LOOKBACK_OCCURRENCES = 4

  # Not meaningfully recurring/forecastable categories for this report --
  # kept out of the category chooser and adjustments table. Products in
  # these categories still appear in the results, just with no dedicated
  # seasonal/buffer row to manage.
  EXCLUDED_CATEGORIES = %w[pot_pie dry_goods wholesale_sandwiches].freeze

  def self.chooser_categories
    Product.product_types.keys - EXCLUDED_CATEGORIES
  end

  Row = Struct.new(:date, :product, :baseline, :seasonal_change, :buffer_percent, :quantity, keyword_init: true)

  def initialize(bakery, start_date, end_date, category_buffers: {})
    @bakery = bakery
    @start_date = start_date.to_date
    @end_date = end_date.to_date
    @category_buffers = category_buffers.stringify_keys
  end

  # => [Row, ...] sorted by date then product name
  def rows
    @rows ||= dates.flat_map do |date|
      seasonal_changes = seasonal_change_for_week(date.beginning_of_week)

      products.map do |product|
        baseline = baseline_for(product, date)
        seasonal_change = seasonal_changes[product.product_type] || 0.0
        buffer_percent = buffer_percent_for(product.product_type)
        quantity = (baseline * (1 + seasonal_change) * (1 + (buffer_percent / 100.0))).round

        Row.new(date: date, product: product, baseline: baseline, seasonal_change: seasonal_change,
          buffer_percent: buffer_percent, quantity: quantity)
      end
    end.sort_by { |row| [row.date, row.product.name] }
  end

  # => { product_type => percent_change }, for the week @start_date falls in.
  # Surfaced so the adjustment is visible on the report, not a black box.
  def category_summary
    seasonal_change_for_week(@start_date.beginning_of_week)
  end

  def buffer_percent_for(category)
    value = @category_buffers[category.to_s]
    value.present? ? value.to_f : DEFAULT_BUFFER_PERCENT
  end

  private

  def dates
    @start_date..@end_date
  end

  def products
    @products ||= @bakery.products.available.order_by_name
  end

  def baseline_for(product, date)
    samples = (1..LOOKBACK_OCCURRENCES).filter_map do |n|
      quantity = history[[date - (n * 7).days, product.id]]
      quantity if quantity&.positive?
    end
    median(samples)
  end

  def median(values)
    return 0 if values.empty?

    sorted = values.sort
    mid = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end

  # Actual delivered quantities (ShipmentItem, via ProductTotalsQuery's
  # invoice source) for every date either the 4-week baseline or the
  # year-over-year seasonal comparison could need, keyed by [date, product_id].
  # One query for the whole report instead of one per date/product.
  def history
    @history ||= begin
      lookback_start = @start_date - ((LOOKBACK_OCCURRENCES * 7) + 6).days
      seasonal_start = @start_date.beginning_of_week - 52.weeks - 7.days
      seasonal_end = @end_date.beginning_of_week - 52.weeks + 6.days
      history_start = [lookback_start, seasonal_start].min
      history_end = [@end_date, seasonal_end].max

      ProductTotalsQuery.new(@bakery, history_start, history_end, source: "generated_invoices")
        .totals.each_with_object({}) { |(date, product, qty), h| h[[date, product.id]] = qty }
    end
  end

  def seasonal_change_for_week(week_start)
    @seasonal_changes ||= {}
    @seasonal_changes[week_start] ||= begin
      this_week_last_year = category_totals_for_week(week_start - 52.weeks)
      prior_week_last_year = category_totals_for_week(week_start - 52.weeks - 7.days)

      Product.product_types.keys.each_with_object({}) do |category, changes|
        prior = prior_week_last_year[category].to_f
        current = this_week_last_year[category].to_f
        changes[category] = prior.positive? ? (current - prior) / prior : 0.0
      end
    end
  end

  def category_totals_for_week(week_start)
    (week_start..week_start + 6.days).each_with_object(Hash.new(0)) do |date, totals|
      products.each do |product|
        qty = history[[date, product.id]]
        totals[product.product_type] += qty if qty
      end
    end
  end
end
