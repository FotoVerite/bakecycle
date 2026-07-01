# frozen_string_literal: true

# == Schema Information
#
# Table name: bakeries
#
#  id                 :integer          not null, primary key
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string
#  phone_number       :string
#  address_street_1   :string
#  address_street_2   :string
#  address_city       :string
#  address_state      :string
#  address_zipcode    :string
#  logo_file_name     :string
#  logo_content_type  :string
#  logo_file_size     :integer
#  logo_updated_at    :datetime
#  kickoff_time       :time             not null
#  last_kickoff       :datetime
#  quickbooks_account :string           not null
#  group_preferments  :boolean          default(TRUE)
#  plan_id            :integer          not null
#  stripe_customer_id :string
#  graph_data         :json
#

class Bakery < ApplicationRecord
  has_many :ingredients, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :routes, dependent: :destroy
  has_many :shipments, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :production_runs, dependent: :destroy
  has_many :vendors, dependent: :destroy

  has_many :shipment_items, through: :shipments
  has_many :order_items, through: :orders

  belongs_to :plan

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
  validates :plan, presence: true
  validates :plan_id, presence: true
  validates :kickoff_time, presence: true
  validates :quickbooks_account, presence: true
  has_attached_file :logo, styles: { invoice: ["1800x200>", :png], thumb: ["300x200>", :png] }
  validates_attachment :logo, content_type: { content_type: %r{\Aimage/(jpeg|png|tiff|bmp)$} }

  accepts_nested_attributes_for(
    :ingredients,
    allow_destroy: false
  )

  def logo_local_file(style = logo.default_style)
    return if logo.path(style).nil?

    if logo.options[:storage] == :filesystem
      path = logo.path(style)
      return path if File.exist?(path)

      return
    end
    return @_tempfile.path if @_tempfile

    @_tempfile = write_logo_to_tempfile(style)
    @_tempfile&.path
  end

  def write_logo_to_tempfile(style)
    tempfile = Tempfile.new("bakecycle-bakery-logo")
    logo.copy_to_local_file(style, tempfile.path)
    tempfile
  rescue StandardError => e
    # The S3 object the DB record points to can be missing or unreadable as an image
    # (e.g. synced data referencing objects that only exist in another environment's
    # bucket -- see db:sync_bakery_logos). Don't let a bad logo crash PDF generation.
    Rails.logger.warn("Bakery##{id}: failed to load logo (style=#{style}): #{e.class}: #{e.message}")
    nil
  end

  def before_kickoff_time?
    !after_kickoff_time?
  end

  def after_kickoff_time?
    kickoff = kickoff_time
    now = Time.zone.now
    # Add a few minutes to account for processing time.
    kickoff_today = Time.zone.local(now.year, now.month, now.day, kickoff.hour, kickoff.min, kickoff.sec) + 5.minutes
    kickoff_today <= now
  end
end
