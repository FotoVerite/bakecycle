class DeliveryListGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, date_string, type = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    new(bakery, date, type)
  end

  def initialize(bakery, date, type)
    @bakery = bakery
    @date = date
    @type = type
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_#{@type}"
  end

  def filename
    "delivery_list_#{@date}.#{@type}"
  end

  def content_type
    if @type == "pdf"
      "application/pdf"
    else
      "application/xlsx"
    end
  end

  def generate
    if @type == "pdf"
      DeliveryListPdf.new(@bakery, @date).render
    else
      DeliveryListXlsx.new(@bakery, @date).generate
    end
  end
end
