namespace :bakecycle do
  desc "Update preferment lead day data to new value"
  task create_plans: :environment do
    Plan.transaction do
      Plan.find_or_create_by!(name: "beta_large", display_name: "Large Bakery")
      Plan.find_or_create_by!(name: "beta_medium", display_name: "Medium Bakery")
      Plan.find_or_create_by!(name: "beta_small", display_name: "Small Bakery")
    end
    puts "Plans Created"
  end
end
