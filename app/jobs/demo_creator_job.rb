class DemoCreatorJob < ActiveJob::Base
  queue_as :demo_creation

  def perform(bakery)
    return if bakery.clients.any?
    DemoCreator.new(bakery).run
  rescue Resque::TermException
    Resque.logger.error "Resque job termination re-queuing #{self} #{bakery}"
    self.class.perform_later(bakery)
  end
end
