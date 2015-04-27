namespace :bakecycle do
  namespace :legacy_import do
    desc 'Import the legacy biencuit bakecycle data'
    task biencuit: :environment do
      require 'legacy_importer'
      puts 'Starting import'
      imported_objects = LegacyImporter.import_all
      reporter = LegacyImporter.report(imported_objects)
      puts "#{reporter.imported_count} objects imported"
      puts reporter.skipped_report
      puts "#{reporter.invalid_count} errored objects"
      puts reporter.csv
    end

    desc 'Email the legacy biencuit bakecycle data'
    task biencuit_email: :environment do
      require 'legacy_importer'
      puts 'Starting import'
      imported_objects = LegacyImporter.import_all
      reporter = LegacyImporter.report(imported_objects)
      puts "#{reporter.imported_count} objects imported"
      puts reporter.skipped_report
      puts "#{reporter.invalid_count} errored objects"
      puts reporter.csv
      reporter.send_email
      puts 'Finished import and email'
    end
  end
end
