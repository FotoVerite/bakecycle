# frozen_string_literal: true

namespace :shipment_graph_data do
  task generate: :environment do
    ShipmentGraphDataService.generate
  end

  task digest_last_week: :environment do
    ShipmentGraphDataService.digest_last_week
  end
end
