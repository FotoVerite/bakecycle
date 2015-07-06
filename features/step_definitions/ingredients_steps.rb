Given(/^There are "(.*?)" bakery ingredients named "(.*?)" and "(.*?)"$/) do |bakery, ing1, ing2|
  bakery = Bakery.find_by(name: bakery)
  create(:ingredient, name: ing1, bakery: bakery)
  create(:ingredient, name: ing2, bakery: bakery)
end

Then(/^I should see a list of ingredients including "(.*?)" and "(.*?)"$/) do |ing1, ing2|
  within '.responsive-table' do
    expect(page).to have_content(ing1)
    expect(page).to have_content(ing2)
  end
end

When(/^I fill out Ingredient form with:$/) do |table|
  select table.hashes[0]['ingredient_type'], from: 'ingredient_ingredient_type'
  fill_in 'ingredient_name', with: table.hashes[0]['name']
  fill_in 'ingredient_description', with: table.hashes[0]['description']
end

Given(/^I am on the edit page for "(.*?)" ingredient$/) do |name|
  ingredient = Ingredient.find_by(name: name)
  visit edit_ingredient_path(ingredient)
end

When(/^I change the ingredient name to "(.*?)"$/) do |name|
  fill_in 'ingredient_name', with: name
end

Then(/^I should see that the ingredient name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

Then(/^The ingredient "(.*?)" should not be present$/) do |client|
  within '.responsive-table' do
    expect(page).to_not have_content(client)
  end
end

Then(/^I should see confirmation that the ingredient "(.*?)" was deleted$/) do |client|
  within '.alert-box' do
    expect(page).to have_content("You have deleted #{client}")
  end
end

When(/^I attempt to visit the "(.*?)" page$/) do |page|
  path_string = "#{page}_path"
  visit send(path_string.to_sym)
end
