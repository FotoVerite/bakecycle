# frozen_string_literal: true

class ProductGraphDataDigestJob < ApplicationJob
  queue_as :operations

  def perform
    ProductGraphDataService.digest_last_week
  end
end
