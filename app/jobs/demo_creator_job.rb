class DemoCreatorJob < ApplicationJob
  queue_as :demo_creation

  def perform(bakery)
    return if bakery.clients.any?

    DemoCreator.new(bakery).run
  end
end
