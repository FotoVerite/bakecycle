namespace :bakecycle do
  namespace :legacy_import do
    desc 'reload all of biencuits data'
    task biencuit_reload: :environment do
      Rake::Task['bakecycle:legacy_import:biencuit_delete'].invoke
      Rake::Task['bakecycle:legacy_import:biencuit'].invoke
      Rake::Task['bakecycle:legacy_import:biencuit_backfill'].invoke
    end

    desc 'delete of of biencuits data'
    task biencuit_delete: :environment do
      require 'legacy_importer'
      puts 'Deleting existing data'
      LegacyImporter.delete_all
      puts 'Done'
    end

    desc 'Import the legacy biencuit bakecycle data'
    task biencuit: :environment do
      require 'legacy_importer'
      puts 'Starting import'
      Resque.inline = true
      LegacyImporter.import_all
      puts 'Import Completed'
    end

    desc 'Email the legacy biencuit bakecycle data'
    task biencuit_email: :environment do
      require 'legacy_importer'
      puts 'Starting import'
      Resque.inline = true
      imported_objects = LegacyImporter.import_and_collect_all
      reporter = LegacyImporter.report(imported_objects)
      puts "#{reporter.imported_count} objects imported"
      puts reporter.skipped_report
      puts "#{reporter.invalid_count} errored objects"
      puts reporter.csv
      reporter.send_email
      puts 'Finished import and email'
    end

    desc 'create shipments and production runs for legacy biencuit data'
    task biencuit_backfill: :environment do
      require 'legacy_importer'
      puts 'Starting backfill'
      LegacyImporter.backfill_data
    end
  end
end
