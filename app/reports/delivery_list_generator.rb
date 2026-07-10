# frozen_string_literal: true

class DeliveryListGenerator
  include Generator
  composite_id bakery: :bakery, date: :date, type: :string

  def initialize(bakery, date, type)
    @bakery = bakery
    @date = date
    @type = type
  end

  def filename
    "Delivery-List-#{@date.iso8601}.#{@type}"
  end

  def generate
    if @type == "pdf"
      DeliveryListPdf.new(@bakery, @date).render
    else
      DeliveryListXlsx.new(@bakery, @date).generate
    end
  end
end
