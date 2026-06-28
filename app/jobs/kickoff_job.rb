# frozen_string_literal: true

class KickoffJob < ApplicationJob
  queue_as :operations

  def perform
    KickoffService.run
  end
end
