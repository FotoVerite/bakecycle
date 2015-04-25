Given(/^There are "(.*?)" bakery recipes named "(.*?)" and "(.*?)"$/) do |bakery, recipe1, recipe2|
  bakery = Bakery.find_by(name: bakery)
  create(:recipe, name: recipe1, bakery: bakery)
  create(:recipe, name: recipe2, bakery: bakery)
end

Then(/^I should see a list of recipes including "(.*?)" and "(.*?)"$/) do |recipe1, recipe2|
  within '.responsive-table' do
    expect(page).to have_content(recipe1)
    expect(page).to have_content(recipe2)
  end
end

When(/^I fill out recipe form with:$/) do |table|
  select table.hashes[0]['recipe_type'], from: 'recipe_recipe_type'
  recipe = table.hashes[0]
  jquery_fill(
    '#recipe_name' => recipe['name'],
    '#recipe_mix_size' => recipe['mix_size'],
    '#recipe_lead_days' => recipe['lead_days'],
    '#recipe_note' => recipe['note'],
    '#recipe_mix_size_unit' => recipe['mix_size_unit']
  )
end

When(/^I change the recipe name to "(.*?)"$/) do |name|
  fill_in 'recipe_name', with: name
end

Then(/^I should see that the recipe name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out recipe item with:$/) do |table|
  item = table.hashes[0]
  jquery_fill(
    'input[id$="bakers_percentage"]:last' => item['percentage'],
    'select[id$="inclusionable_id_type"]' => item['inclusionable_id_type']
  )
end

Then(/^I should see confirmation the recipe "(.*?)" was deleted$/) do |recipe|
  within '.alert-box' do
    expect(page).to have_content("You have deleted #{recipe}")
  end
end

Then(/^the recipe "(.*?)" should not be present$/) do |recipe|
  within '.responsive-table' do
    expect(page).to_not have_content(recipe)
  end
end
