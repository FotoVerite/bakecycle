# frozen_string_literal: true

class ProductTotalsDateRangeGenerator
  include Generator

  def self.find(global_id)
    bakery_id, date_string, end_date_string, remainder = global_id.split("_", 4)
    bakery = Bakery.find(bakery_id)
    end_date = parse_date(end_date_string)
    if end_date
      source = remainder.to_s
        .delete_suffix("_product_totals_date_range")
        .delete_suffix("_delivery_product_projection")
        .presence
    else
      source = [end_date_string, remainder].compact.join("_")
        .delete_suffix("_product_totals_date_range")
        .delete_suffix("_delivery_product_projection")
        .presence
    end
    new(bakery, Date.iso8601(date_string), end_date: end_date, source: source)
  end

  def self.parse_date(value)
    Date.iso8601(value.to_s)
  rescue ArgumentError
    nil
  end

  attr_reader :end_date, :source

  def initialize(bakery, date, end_date: nil, source: nil)
    @bakery = bakery
    @date = date.to_date
    @end_date = (end_date || @date + ProductTotalsDateRangeXlsx::HORIZON_DAYS.days).to_date
    @source = ProductTotalsDateRangeXlsx.normalize_source(source)
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_#{@end_date.iso8601}_#{source}_product_totals_date_range"
  end

  def filename
    if @date == @end_date
      date_part = @date.iso8601
    else
      date_part = "#{@date.iso8601}-through-#{@end_date.iso8601}"
    end

    if source == "generated_invoices"
      "CreatedShipmentProductTotals-#{date_part}.xlsx"
    else
      "OrderProductTotals-#{date_part}.xlsx"
    end
  end

  def generate
    ProductTotalsDateRangeXlsx.new(@bakery, @date, end_date: @end_date, source: source).generate
  end
end
