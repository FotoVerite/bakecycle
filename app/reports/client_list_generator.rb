# frozen_string_literal: true

class ClientListGenerator
  include Generator
  composite_id bakery: :bakery, type: :string

  def initialize(bakery, type)
    @bakery = bakery
    @type = type
    @date = Time.zone.today
  end

  def filename
    "Client-List-#{@type.to_s.titleize}-#{@date.iso8601}.xlsx"
  end

  def generate
    ClientListXlsx.new(@bakery, @date, @type).generate
  end
end
