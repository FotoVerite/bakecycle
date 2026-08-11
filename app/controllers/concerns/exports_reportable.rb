# frozen_string_literal: true

# Shared response handling for the ~30 report/export trigger actions. Centralizes
# the switch away from opening a new browser tab per export: triggers now stay on
# the current page and get a turbo_stream response that appends the pending row
# to the header tray and /file_exports history (both flip to "ready" live via the
# ExporterJob broadcast once generation finishes). The classic full-page redirect
# to file_exports#show is kept as the format.html fallback for non-JS/no-Turbo
# requests (e.g. a direct link opened in a fresh tab).
module ExportsReportable
  extend ActiveSupport::Concern

  def create_export_and_respond(generator)
    file_export = ExporterJob.create(current_user, current_bakery, generator)

    # Some trigger links carry a `.pdf`/`.xlsx`/`.csv` extension in the URL --
    # either as a leftover from the old "open the file in a new tab" design or
    # because the controller reads the export type from `params[:format]` (e.g.
    # DailyTotalsController). That extension pins `request.format` to the binary
    # type, so a plain `respond_to` with only `html`/`turbo_stream` blocks raises
    # `ActionController::UnknownFormat` (406) for every one of those triggers.
    # Key off Turbo's own hint instead -- Turbo adds the turbo-stream MIME to the
    # Accept header on `data-turbo-stream` requests regardless of URL extension,
    # while a plain browser hitting the link in a fresh tab still gets the
    # full-page redirect fallback.
    if turbo_stream_export_request?
      render turbo_stream: [
        turbo_stream.prepend("export_tray_list", partial: "file_exports/tray_item",
                                                 locals: { file_export: file_export, variant: :enter,
                                                           auto_download: true }),
        turbo_stream.prepend("file_exports_list", partial: "file_exports/history_row",
                                                  locals: { file_export: file_export, variant: :enter }),
        *overflow_removal_streams(file_export)
      ]
    else
      redirect_to file_export
    end
  end

  private

  def turbo_stream_export_request?
    request.format.turbo_stream? ||
      request.headers["Accept"].to_s.include?(Mime[:turbo_stream].to_s)
  end

  # Prepending grows the tray/history lists past the 10-item display cap. Since
  # exports are never pruned from the DB (invoices must be retained), the cap is
  # display-only -- evict whatever just fell outside the 10 most recent here.
  #
  # `.limit` is load-bearing, not cosmetic: on a real bakery with a long history
  # (tens of thousands of retained exports), `.offset(9)` with no `.limit` loads
  # and iterates *every row past the 10th* -- confirmed to take 6-7s end-to-end
  # against a 123k-row table. A single click can only ever push a handful of
  # rows past the cap, so this is bounded generously, not tightly.
  def overflow_removal_streams(file_export)
    overflow = current_user.file_exports
      .where.not(id: file_export.id)
      .order(created_at: :desc)
      .offset(9)
      .limit(20)
    overflow.flat_map do |stale|
      [
        turbo_stream.remove("tray_file_export_#{stale.id}"),
        turbo_stream.remove("file_export_#{stale.id}")
      ]
    end
  end
end
