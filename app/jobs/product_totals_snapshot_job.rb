# frozen_string_literal: true

# Nightly baseline of every bakery's order projection. Runs before the
# morning rush of shipment generation/edits so "what did the plan look like
# this morning" is always answerable. Shipments don't need this treatment:
# shipment_items already denormalize their contents at creation time.
class ProductTotalsSnapshotJob < ApplicationJob
  queue_as :operations

  WINDOW_DAYS = 14

  def perform
    start_date = Time.zone.today
    end_date = start_date + (WINDOW_DAYS - 1).days

    Bakery.find_each do |bakery|
      next if captured_today?(bakery)

      ProductTotalsSnapshot.capture!(
        bakery: bakery,
        start_date: start_date,
        end_date: end_date,
        source: ProductTotalsQuery::DEFAULT_SOURCE,
        label: ProductTotalsSnapshot::NIGHTLY
      )
    end
  end

  private

  # Reruns/retries on the same day must not double-capture.
  def captured_today?(bakery)
    ProductTotalsSnapshot
      .where(bakery: bakery, label: ProductTotalsSnapshot::NIGHTLY)
      .where(created_at: Time.current.all_day)
      .exists?
  end
end
