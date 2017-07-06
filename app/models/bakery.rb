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
#

class Bakery < ApplicationRecord
  has_many :ingredients
  has_many :clients
  has_many :recipes
  has_many :orders
  has_many :products
  has_many :routes
  has_many :shipments
  has_many :users
  has_many :production_runs

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

  def logo_local_file(style = logo.default_style)
    return if logo.path(style).nil?
    return logo.path(style) if logo.options[:storage] == :filesystem
    return @_tempfile.path if @_tempfile

    @_tempfile = write_logo_to_tempfile(style)
    @_tempfile.path
  end

  def write_logo_to_tempfile(style)
    tempfile = Tempfile.new("bakecycle-bakery-logo")
    logo.copy_to_local_file(style, tempfile.path)
    tempfile
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
