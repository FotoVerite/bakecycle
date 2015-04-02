namespace :bakecycle do
  desc 'Create shipments for active orders and production runs that contain those shipments'
  task create_kickoffs: :environment do
    Rails.logger.info 'Creating shipments and production runs'
    KickoffService.run
    Rails.logger.info 'Done Creating'
  end
end
