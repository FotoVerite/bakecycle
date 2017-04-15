class DailyTotalGenerator
  include GlobalID::Identification

  def self.find(global_id)
    bakery_id, date_string, show_routes = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    show_routes = show_routes == "true"
    new(bakery, date, show_routes)
  end

  def initialize(bakery, date, show_routes = true)
    @bakery = bakery
    @date = date.to_date
    @show_routes = show_routes
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_#{@show_routes}"
  end

  def filename
    "DailyTotal.pdf"
  end

  def generate
    pdf.render
  end

  private

  def pdf
    DailyTotalPdf.new(@bakery, @date, @show_routes)
  end
end
