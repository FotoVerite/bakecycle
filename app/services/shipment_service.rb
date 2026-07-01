# frozen_string_literal: true

class ShipmentService
  attr_reader :bakery, :run_time

  def initialize(bakery, run_time)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    ShipmentHorizonService.new(bakery, run_time).run
  end
end
