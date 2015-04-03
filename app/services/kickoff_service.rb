class KickoffService
  attr_reader :bakery, :run_time

  def initialize(bakery, run_time = Time.now)
    @bakery = bakery
    @run_time = run_time
  end

  def self.run(run_time = Time.now)
    Bakery.find_each do |bakery|
      new(bakery, run_time).run
    end
  end

  def run
    return unless kickoff?
    ShipmentService.new(bakery, run_time).run
    ProductionRunService.new(bakery).create_production_run
  end

  def kickoff?
    after_kickoff_time? && kickoff_expired?
  end

  private

  def after_kickoff_time?
    kickoff = bakery.kickoff_time
    kickoff_today = Time.new(run_time.year, run_time.month, run_time.day, kickoff.hour, kickoff.min, kickoff.sec)
    kickoff_today < run_time
  end

  def kickoff_expired?
    return true unless bakery.last_kickoff
    (bakery.last_kickoff + 24.hours) < run_time
  end
end
