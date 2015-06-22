namespace :bakecycle do
  desc 'Update preferment lead day data to new value'
  task create_bakery_plans: :environment do
    puts 'Creating Plans'
    Plan.transaction do
      Plan.first_or_create(name: 'beta_large', display_name: 'Large Bakery')
      Plan.first_or_create(name: 'beta_medium', display_name: 'Medium Bakery')
      Plan.first_or_create(name: 'beta_small', display_name: 'Small Bakery')
    end
    puts 'Plans Created'
  end
end
