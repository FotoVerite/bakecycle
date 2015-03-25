namespace :bakecycle do
  desc 'Create shipments for active orders'
  task create_shipments: :environment do
    Rails.logger.info 'Creating shipments'
    ShipmentService.run
    Rails.logger.info 'Creating shipments done'
  end
end
