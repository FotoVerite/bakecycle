namespace :bakecycle do
  namespace :legacy_import do
    desc 'Import the legacy biencuit bakecycle data'
    task biencuit_import: :environment do
      require 'legacy_importer'
      Rails.logger.warn 'Starting import'
      biencuit = Bakery.find_by!(name: 'Bien Cuit')
      importer = LegacyImporter.new(bakery: biencuit)
      valid_clients, invalid_clients = importer.clients.import!
      puts "#{valid_clients.count} client imported"
      puts "#{invalid_clients.count} errored client imports"
      puts LegacyClientImporter::Report.new(invalid_clients).csv
      Rails.logger.warn 'Finished import'
    end

    desc 'Email the legacy biencuit bakecycle data'
    task biencuit_email: :environment do
      require 'legacy_importer'
      biencuit = Bakery.find_by!(name: 'Bien Cuit')
      importer = LegacyImporter.new(bakery: biencuit)
      _valid_clients, invalid_clients = importer.clients.import!
      puts "#{invalid_clients.count} errored client imports"
      LegacyClientImporter::Report.new(invalid_clients).send_email
    end
  end
end
