# frozen_string_literal: true

class GroceryListGenerator
  include Generator

  def self.find(global_id)
    bakery_id, date_string = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    date = Date.iso8601(date_string)
    new(bakery, date)
  end

  def initialize(bakery, date)
    @bakery = bakery
    @date = date.to_date
  end

  def id
    "#{@bakery.id}_#{@date.iso8601}_grocery_list"
  end

  def filename
    "Grocery-List-#{@date.iso8601}.xlsx"
  end

  def generate
    GroceryListXlsx.new(@bakery, @date).generate
  end
end
