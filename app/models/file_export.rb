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
end
