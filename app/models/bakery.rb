class Bakery < ActiveRecord::Base
  has_many :ingredients
  has_many :clients
  has_many :recipes
  has_many :orders
  has_many :products
  has_many :routes
  has_many :shipments
  has_many :users

  validates :name, presence: true, uniqueness: true, length: { maximum: 150 }
  has_attached_file :logo, styles: { invoice: '1800x200>', thumb: '300x200>' }
  validates_attachment :logo, content_type: { content_type: /^image\/(jpeg|png|tiff|bmp)$/ }

  def logo_local_file(style = logo.default_style)
    return if logo.path(style).nil?
    return logo.path(style) if logo.options[:storage] == :filesystem
    return @_tempfile.path if @_tempfile

    @_tempfile = write_logo_to_tempfile(style)
    @_tempfile.path
  end

  def write_logo_to_tempfile(style)
    tempfile = Tempfile.new('bakecycle-bakery-logo')
    logo.copy_to_local_file(style, tempfile.path)
    tempfile
  end
end
