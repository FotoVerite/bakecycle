namespace :bakecycle do
  desc 'Create shipments for active orders and production runs that contain those shipments'
  task kickoff: :environment do
    Rails.logger.warn 'Creating shipments and production runs'
    KickoffService.run
    Rails.logger.warn 'Done Creating'
  end
end
