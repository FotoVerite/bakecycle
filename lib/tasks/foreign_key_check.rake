namespace :immigrant do
  desc 'Checks for missing foreign key relationships in the database'
  task check_keys: :environment do
    Rails.application.eager_load!

    config_file = '.immigrant.yml'
    if File.exist?(config_file)
      ignore_keys = YAML.load_file(config_file)
    else
      ignore_keys = []
    end

    keys, warnings = Immigrant::KeyFinder.new.infer_keys
    warnings.values.each { |warning| $stderr.puts "WARNING: #{warning}" }

    keys.select! do |key|
      !ignore_keys.include?('from_table' => key.from_table, 'to_table' => key.to_table)
    end

    keys.each do |key|
      column = key.options[:column]
      pk = key.options[:primary_key]
      $stderr.puts "Missing foreign key relationship on '#{key.from_table}.#{column}' to '#{key.to_table}.#{pk}'"
    end

    if keys.present?
      puts 'Found missing foreign keys, run `rails generate immigration MigrationName` or add them.'
      puts "Or add them to #{config_file} to ignore them."
      exit keys.count
    end
  end
end
