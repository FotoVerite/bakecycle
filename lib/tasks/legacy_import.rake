namespace :bakecycle do
  namespace :legacy_import do
    desc 'Import the legacy biencuit bakecycle data'
    task biencuit: :environment do
      require 'legacy_importer'
      Rails.logger.info 'Starting import'
      biencuit = Bakery.find_by!(name: 'Biencuit')
      importer = LegacyImporter.new(bakery: biencuit)
      valid_clients, error_clients = importer.import_clients
      puts "#{error_clients.count} errored client imports"
      Rails.logger.info 'Finished import'
    end
  end
end
