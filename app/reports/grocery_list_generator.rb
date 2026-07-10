# frozen_string_literal: true

class GroceryListGenerator
  include Generator
  composite_id bakery: :bakery, date: :date

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def filename
    "Grocery-List-#{@date.iso8601}.xlsx"
  end

  def generate
    GroceryListXlsx.new(@bakery, @date).generate
  end
end
