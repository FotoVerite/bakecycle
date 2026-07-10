# frozen_string_literal: true

class VipListGenerator
  include Generator
  composite_id bakery: :bakery

  def initialize(bakery)
    @bakery = bakery
    @date = Time.zone.today
  end

  def filename
    "VIP-List-#{@date.iso8601}.xlsx"
  end

  def generate
    VipListXlsx.new(@bakery).generate
  end
end
