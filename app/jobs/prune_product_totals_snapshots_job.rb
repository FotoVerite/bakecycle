# frozen_string_literal: true

# Keeps nightly product-totals snapshots bounded (same shape as
# PurgeOldVersionsJob). Only NIGHTLY snapshots are pruned -- report_export
# and any future human-intentional labels are kept indefinitely; they're the
# ones someone asks about months later, and they're rare enough to be free.
class PruneProductTotalsSnapshotsJob < ApplicationJob
  queue_as :operations

  RETENTION = 90.days
  BATCH_SIZE = 500

  def perform
    cutoff = Time.current - RETENTION

    loop do
      ids = ProductTotalsSnapshot
        .where(label: ProductTotalsSnapshot::NIGHTLY)
        .where(created_at: ...cutoff)
        .limit(BATCH_SIZE)
        .pluck(:id)
      break if ids.empty?

      ProductTotalsSnapshotRow.where(snapshot_id: ids).delete_all
      ProductTotalsSnapshot.where(id: ids).delete_all
      sleep(0.2)
    end
  end
end
