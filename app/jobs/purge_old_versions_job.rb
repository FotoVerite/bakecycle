# frozen_string_literal: true

# Keeps the PaperTrail `versions` table bounded. Without this it grows
# unbounded forever (see CLAUDE.md / versions:purge_order_item_backlog).
class PurgeOldVersionsJob < ApplicationJob
  RETENTION = 90.days
  BATCH_SIZE = 10_000

  def perform
    cutoff = Time.current - RETENTION

    loop do
      ids = PaperTrail::Version.where(created_at: ...cutoff).limit(BATCH_SIZE).pluck(:id)
      break if ids.empty?

      PaperTrail::Version.where(id: ids).delete_all
      sleep(0.2)
    end
  end
end
