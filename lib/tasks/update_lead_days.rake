namespace :bakecycle do
  desc "Update preferment lead day data to new value"
  task update_lead_days: :environment do
    puts "Starting Task"
    Recipe.transaction do
      Recipe.where(recipe_type: Recipe.recipe_types[:preferment]).update_all(lead_days: 1)
      Recipe.where(recipe_type: Recipe.recipe_types[:preferment]).find_each(&:touch)
    end
    puts "Lead days updated"
  end
end
