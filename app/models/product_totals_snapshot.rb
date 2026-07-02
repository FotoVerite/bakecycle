# frozen_string_literal: true

# Point-in-time capture of product totals (order projection or created
# shipments) for later comparison. Orders mutate in place, so "what did the
# plan say on July 2nd" is unanswerable unless it was captured on July 2nd --
# these rows are that capture. Written nightly by ProductTotalsSnapshotJob;
# nightly snapshots are pruned after PruneProductTotalsSnapshotsJob::RETENTION,
# any other label is kept indefinitely.
class ProductTotalsSnapshot < ApplicationRecord
  NIGHTLY = "nightly"

  belongs_to :bakery
  has_many :rows,
    class_name: "ProductTotalsSnapshotRow",
    foreign_key: :snapshot_id,
    inverse_of: :snapshot,
    dependent: :delete_all

  validates :source, inclusion: { in: ProductTotalsQuery::SOURCES }
  validates :label, presence: true
  validates :start_date, :end_date, presence: true

  # Computes totals through the same query the Product Totals report uses and
  # freezes them. product_name is denormalized so rows stay meaningful after
  # products are renamed or deleted.
  def self.capture!(bakery:, start_date:, end_date:, source:, label:)
    source = ProductTotalsQuery.normalize_source(source)
    totals = ProductTotalsQuery.new(bakery, start_date, end_date, source: source).totals

    transaction do
      snapshot = create!(
        bakery: bakery,
        source: source,
        label: label,
        start_date: start_date,
        end_date: end_date
      )
      rows = totals.map do |delivery_date, product, quantity|
        {
          snapshot_id: snapshot.id,
          delivery_date: delivery_date,
          product_id: product.id,
          product_name: product.name,
          quantity: quantity
        }
      end
      ProductTotalsSnapshotRow.insert_all(rows) if rows.any?
      snapshot
    end
  end
end
