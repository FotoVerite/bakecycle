# frozen_string_literal: true

class DailyTotalGenerator
  include Generator
  composite_id bakery: :bakery, date: :date, type: :string, show_routes: :bool

  def initialize(bakery, date, type, show_routes = true)
    @bakery = bakery
    @date = date.to_date
    @type = type
    @show_routes = show_routes
  end

  def filename
    "Daily-Total-#{@date.iso8601}.#{@type}"
  end

  def generate
    if @type == "pdf"
      DailyTotalPdf.new(@bakery, @date).render
    else
      DailyTotalXlsx.new(@bakery, @date).generate
    end
  end
end
