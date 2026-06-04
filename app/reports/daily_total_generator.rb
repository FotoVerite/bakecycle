class DailyTotalGenerator
  include Generator

  def self.find(global_id)
    bakery_id, date_string, type, show_routes = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    show_routes = show_routes == "true"
    new(bakery, date, type, show_routes)
  end

  def initialize(bakery, date, type, show_routes = true)
    @bakery = bakery
    @date = date.to_date
    @type = type
    @show_routes = show_routes
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_#{@type}_#{@show_routes}"
  end

  def filename
    "DailyTotal_#{@date}_#{@show_routes}.#{@type}"
  end

  def generate
    if @type == "pdf"
      DailyTotalPdf.new(@bakery, @date).render
    else
      DailyTotalXlsx.new(@bakery, @date).generate
    end
  end
end
