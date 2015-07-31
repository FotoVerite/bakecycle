class Bakery < ActiveRecord::Base
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
end
