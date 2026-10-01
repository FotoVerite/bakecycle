# frozen_string_literal: true

# Closes the one hole in ExporterJob's own error handling.
#
# ExporterJob rescues anything its `perform` raises, and `record_unexpected_failure`
# catches arguments that fail to deserialize. Neither fires when the job is failed
# *externally* -- a supervisor shutdown mid-run calls "Fail claimed jobs" on whatever
# was in flight, so no Ruby in our codebase ever executes for that job. The FileExport
# row is then stranded with no attachment, and the tray/history row says "Generating..."
# forever. (Confirmed 2026-09-01: two Total Sales exports were killed by a 13:15 restart,
# and the hourly clear_solid_queue_failed_jobs discarded the failed executions 12 minutes
# later, erasing even the record that they'd failed. 250 rows had accumulated this way.)
#
# Deliberately conservative: a row is only swept once it is older than STALE_AFTER *and*
# no unfinished Solid Queue job still references it. A legitimately slow export (a
# multi-year Total Sales run is hundreds of thousands of rows) keeps its live job row the
# whole time it runs, so it is never touched no matter how long it takes.
class SweepStalledExportsJob < ApplicationJob
  queue_as :operations

  STALE_AFTER = 1.hour

  class StalledExportError < StandardError
    def initialize(file_export)
      super("Export generation was interrupted before it finished (queued #{file_export.created_at.utc.iso8601}). " \
            "This usually means the server restarted mid-export. Please try running it again.")
      # ErrorReport renders `backtrace.join` unconditionally, and an exception
      # that is constructed rather than raised has a nil backtrace -- there is
      # no Ruby frame to capture here, since the whole point is that the job
      # died without executing any of our code.
      set_backtrace([])
    end
  end

  def perform(stale_after: STALE_AFTER)
    swept = 0
    candidates(stale_after).find_each do |file_export|
      next if live_job?(file_export)

      swept += 1 if file_export.mark_failed!(StalledExportError.new(file_export))
    end
    Rails.logger.info("SweepStalledExportsJob marked #{swept} stalled export(s) as failed") if swept.positive?
    swept
  end

  private

  def candidates(stale_after)
    FileExport.where(file_file_name: nil).where(created_at: ..stale_after.ago)
  end

  # Solid Queue stores ActiveJob's serialized arguments as JSON, with each
  # GlobalID argument rendered as {"_aj_globalid" => "gid://bakecycle/FileExport/<uuid>"}.
  # Matching on the gid substring is enough to tell "a worker still owns this export"
  # from "nothing is coming back for it", without having to parse the payload.
  def live_job?(file_export)
    unfinished_export_jobs.any? { |arguments| arguments.include?("/FileExport/#{file_export.id}") }
  end

  # Loaded once per run, not once per row -- the unfinished set is tiny (usually
  # empty), while the stalled-row backlog can be in the hundreds.
  def unfinished_export_jobs
    @unfinished_export_jobs ||=
      SolidQueue::Job.where(finished_at: nil, class_name: "ExporterJob").pluck(:arguments).map(&:to_s)
  rescue StandardError => e
    # If Solid Queue's tables can't be read for any reason, sweep nothing rather
    # than risk failing an export that is genuinely still running.
    Rails.logger.warn("SweepStalledExportsJob could not read Solid Queue jobs: #{e.class}")
    raise
  end
end
