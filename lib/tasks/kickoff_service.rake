namespace :bakecycle do
  desc "Create shipments for active orders and production runs that contain those shipments"
  task kickoff: :environment do
    puts "Kickoff Starting"
    KickoffService.run
    puts "Kickoff finished"
  end
end
