# frozen_string_literal: true

class ClientsPerProductForWeekGenerator
  include Generator
  composite_id bakery: :bakery, date: :date

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def filename
    "Clients-Per-Product-#{@date.iso8601}.xlsx"
  end

  def generate
    ClientsPerProductForWeekXlsx.new(@bakery, @date).generate
  end
end
