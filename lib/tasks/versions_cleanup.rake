# frozen_string_literal: true

namespace :versions do
  desc "One-off: delete all PaperTrail OrderItem versions (touch-noise backlog, see CLAUDE.md)"
  task purge_order_item_backlog: :environment do
    batch_size = (ENV["BATCH_SIZE"] || 10_000).to_i
    sleep_between_batches = (ENV["SLEEP"] || 0.2).to_f
    scope = PaperTrail::Version.where(item_type: "OrderItem")
    total = scope.count
    puts "Deleting #{total} OrderItem versions in batches of #{batch_size}..."

    deleted = 0
    loop do
      ids = scope.limit(batch_size).pluck(:id)
      break if ids.empty?

      PaperTrail::Version.where(id: ids).delete_all
      deleted += ids.size
      puts "  deleted #{deleted}/#{total}"
      sleep(sleep_between_batches)
    end

    puts "Done. Run `VACUUM (VERBOSE, ANALYZE) versions;` to reclaim disk space."
  end
end
