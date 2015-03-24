namespace :bakecycle do
  namespace :legacy_import do
    desc 'Import the legacy biencuit bakecycle data'
    task biencuit_import: :environment do
      require 'legacy_importer'
      Rails.logger.info 'Starting import'
      biencuit = Bakery.find_by!(name: 'Biencuit')
      importer = LegacyImporter.new(bakery: biencuit)
      _valid_clients, invalid_clients = importer.import_clients
      puts "#{invalid_clients.count} errored client imports"
      importer.invalid_client_report(invalid_clients)
      Rails.logger.info 'Finished import'
    end

    desc 'Email the legacy biencuit bakecycle data'
    task biencuit_email: :environment do
      require 'legacy_importer'
      biencuit = Bakery.find_by!(name: 'Biencuit')
      importer = LegacyImporter.new(bakery: biencuit)
      _valid_clients, invalid_clients = importer.import_clients
      puts "#{invalid_clients.count} errored client imports"
      importer.invalid_client_csv_email(invalid_clients)
    end
  end
end
