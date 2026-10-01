# frozen_string_literal: true

# == Schema Information
#
# Table name: file_exports
#
#  id                :uuid             not null, primary key
#  bakery_id         :integer          not null
#  user_id           :integer
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_fingerprint  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class FileExport < ApplicationRecord
  belongs_to :bakery
  # Optional only so pre-backfill legacy rows stay valid; every export created
  # through ExporterJob.create carries the requesting user for per-person scoping.
  belongs_to :user, optional: true
  has_attached_file :file,
                    s3_headers: { content_disposition: "attachment" },
                    use_timestamp: false,
                    default_url: "",
                    url: "/system/:class/:id/:attachment/:filename"

  validates :bakery, presence: true
  do_not_validate_attachment_file_type :file

  def ready?
    file.present?
  end

  # No dedicated status column -- ready?/failed? are both derived from the
  # attached file, matching the "no schema changes" design decision. A failed
  # generation still attaches a file (an error report), so this is the only
  # way to tell it apart from a real successful export.
  def failed?
    ready? && file_file_name.to_s.end_with?("-error.pdf")
  end

  def download_url
    return unless ready?

    file.expiring_url(10.minutes.to_i)
  end

  # Lucide icon name for the tray/history "what kind of file is this" glance.
  def format_icon
    case file_content_type
    when "application/pdf" then "file-text"
    when /spreadsheetml/, "text/csv" then "file-spreadsheet"
    else "file"
    end
  end

  # Keyed per-user, not per-bakery: exports are private to the person who
  # requested them, so live tray/history updates must only reach that user's
  # subscription (otherwise one bakery's staff receive each other's export HTML).
  def self.broadcast_stream_for(user)
    "file_exports:user:#{user.id}"
  end

  def broadcast_stream
    self.class.broadcast_stream_for(user)
  end

  # Attach the standard error-report PDF and tell the tray/history rows to
  # re-render. Lives here rather than on ExporterJob because two different
  # callers need it: the job's own rescue (a generator that raised in-process)
  # and SweepStalledExportsJob (a job killed *externally* -- e.g. a supervisor
  # restart failing its claimed executions -- which never gets to run any
  # rescue at all, and so used to strand the row at "Generating..." forever).
  def mark_failed!(exception)
    return false if ready?

    Sentry.capture_exception(exception) if defined?(Sentry)

    self.file_content_type = "application/pdf"
    self.file = FakeFileIO.new("export-error.pdf", ErrorReport.new(exception).render)
    save!
    broadcast_update
    true
  end

  # Broadcast twice: once for the header tray's row, once for the /file_exports
  # history page's row. Turbo silently no-ops a replace targeting a DOM id that
  # isn't present on the current page, so this is safe even though only one of
  # the two targets exists on any given page.
  def broadcast_update
    { "tray_file_export_#{id}" => "file_exports/tray_item",
      "file_export_#{id}" => "file_exports/history_row" }.each do |target, partial|
      Turbo::StreamsChannel.broadcast_replace_to(
        broadcast_stream,
        target: target,
        partial: partial,
        locals: { file_export: self, variant: :flash }
      )
    end
  end
end
