namespace :bakecycle do
  desc 'Update preferment lead day data to new value'
  task create_plans: :environment do
    puts 'Creating Plans'
    Plan.transaction do
      Plan.where(name: 'beta_large', display_name: 'Large Bakery').first_or_create!
      Plan.where(name: 'beta_medium', display_name: 'Medium Bakery').first_or_create!
      Plan.where(name: 'beta_small', display_name: 'Small Bakery').first_or_create!
    end
    puts 'Plans Created'
  end
end
