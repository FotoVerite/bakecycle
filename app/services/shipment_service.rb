class ShipmentService
  attr_reader :bakery, :run_time

  class << self
    include Skylight::Helpers
    def run(run_time = Time.zone.now)
      Bakery.find_each do |bakery|
        new(bakery, run_time).run
      end
    end
    instrument_method :run, title: 'Shipment Service'
  end

  def initialize(bakery, run_time)
    @bakery = bakery
    @run_time = run_time
  end

  def run
    bakery.update!(last_kickoff: run_time)
    process_bakery
  end

  def process_bakery
    Client.where(bakery: bakery).find_each do |client|
      process_client(client)
    end
  end

  def process_client(client)
    max_lead_time = client.orders.map(&:total_lead_days).max
    return if max_lead_time.nil?
    (1..max_lead_time).each do |lead|
      ship_date = run_time + lead.days
      Order.active(client, ship_date).each do |order|
        ShipmentCreator.new(order, ship_date).create!
      end
    end
  end
end
