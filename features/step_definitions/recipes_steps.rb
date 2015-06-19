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
  recipe = table.hashes[0]
  jquery_fill(
    '[data-field="name"]' => recipe['name'],
    '[data-field="mixSize"]' => recipe['mix_size'],
    '[data-field="leadDays"]' => recipe['lead_days'],
    '[data-field="note"]' => recipe['note'],
    '[data-field="mixSizeUnit"]' => recipe['mix_size_unit'],
    '[data-field="recipeType"]' => recipe['recipe_type']
  )
end

When(/^I change the recipe name to "(.*?)"$/) do |name|
  jquery_fill('[data-field="name"]' => name)
end

Then(/^I should see that the recipe name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out recipe item with:$/) do |table|
  item = table.hashes[0]
  jquery_fill(
    '.bakers_percentage_input:last' => item['percentage'],
    '.inclusionable_id_type:last' => item['inclusionable_id_type']
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
