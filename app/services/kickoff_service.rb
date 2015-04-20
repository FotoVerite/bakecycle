class KickoffService
  attr_reader :bakery, :run_time

  class << self
    include Skylight::Helpers
    def run(run_time = Time.zone.now)
      Bakery.find_each do |bakery|
        new(bakery, run_time).run
      end
    end
    instrument_method :run, title: 'Kickoff Service'
  end

  def initialize(bakery, run_time = Time.zone.now)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    return unless kickoff?
    ShipmentService.new(bakery, run_time).run
    ProductionRunService.new(bakery, run_time).create_production_run
  end

  def kickoff?
    after_kickoff_time? && kickoff_expired?
  end

  private

  def after_kickoff_time?
    kickoff = bakery.kickoff_time
    kickoff_today = Time.zone.local(run_time.year, run_time.month, run_time.day, kickoff.hour, kickoff.min, kickoff.sec)
    kickoff_today < run_time
  end

  def kickoff_expired?
    return true unless bakery.last_kickoff
    (bakery.last_kickoff + 24.hours) < run_time
  end
end
