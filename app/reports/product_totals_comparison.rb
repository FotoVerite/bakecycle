# frozen_string_literal: true

# Diffs two product-totals datasets keyed by [delivery_date, product_id].
# A "source" is just a hash of that shape -- built from the live query
# (.live) or a stored snapshot (.from_snapshot) -- so any two of
# orders/shipments/snapshots compare through the same interface.
class ProductTotalsComparison
  Row = Struct.new(:delivery_date, :product_id, :product_name, :baseline_quantity, :compare_quantity) do
    def difference
      compare_quantity - baseline_quantity
    end

    def match?
      difference.zero?
    end
  end

  def self.live(bakery, start_date, end_date, source:)
    ProductTotalsQuery.new(bakery, start_date, end_date, source: source).totals.to_h do |date, product, quantity|
      [[date, product.id], { name: product.name, quantity: quantity }]
    end
  end

  def self.from_snapshot(snapshot, start_date, end_date)
    snapshot.rows.where(delivery_date: start_date..end_date).to_h do |row|
      [[row.delivery_date, row.product_id], { name: row.product_name, quantity: row.quantity }]
    end
  end

  def initialize(baseline, compare)
    @baseline = baseline
    @compare = compare
  end

  def rows
    @_rows ||= (@baseline.keys | @compare.keys).map do |key|
      delivery_date, product_id = key
      Row.new(delivery_date, product_id, name_for(key), quantity_for(@baseline, key), quantity_for(@compare, key))
    end.sort_by { |row| [row.delivery_date, row.product_name] }
  end

  def differing_rows
    rows.reject(&:match?)
  end

  # Daily totals over the full range (zeros where neither side has rows),
  # so a chart shows a continuous shape rather than skipping quiet days.
  def totals_by_date(range)
    by_date = rows.group_by(&:delivery_date)
    range.map do |date|
      day_rows = by_date.fetch(date, [])
      [date, day_rows.sum(&:baseline_quantity), day_rows.sum(&:compare_quantity)]
    end
  end

  private

  def name_for(key)
    @baseline.dig(key, :name) || @compare.dig(key, :name)
  end

  def quantity_for(side, key)
    side.dig(key, :quantity) || 0
  end
end
