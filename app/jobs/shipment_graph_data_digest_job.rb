# frozen_string_literal: true

class ShipmentGraphDataDigestJob < ApplicationJob
  queue_as :operations

  def perform
    ShipmentGraphDataService.digest_last_week
  end
end
