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
    respond_to do |format|
      format.html { redirect_to file_export }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("export_tray_list", partial: "file_exports/tray_item", locals: { file_export: file_export, variant: :enter }),
          turbo_stream.prepend("file_exports_list", partial: "file_exports/history_row", locals: { file_export: file_export, variant: :enter }),
          *overflow_removal_streams(file_export)
        ]
      end
    end
  end

  private

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
    overflow = current_bakery.file_exports
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
