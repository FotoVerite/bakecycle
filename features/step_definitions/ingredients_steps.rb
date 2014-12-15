Given(/^There are ingredients named "(.*?)","(.*?)" and "(.*?)"$/) do |ingredient1, ingredient2, ingredient3|
  FactoryGirl.create(:ingredient, name: ingredient1)
  FactoryGirl.create(:ingredient, name: ingredient2)
  FactoryGirl.create(:ingredient, name: ingredient3)
end

Then(/^I should see a list of ingredients including "(.*?)", "(.*?)" and "(.*?)"$/) do |ing1, ing2, ing3|
  expect(page).to have_content(ing1)
  expect(page).to have_content(ing2)
  expect(page).to have_content(ing3)
end

Then(/^I should be redirected to an ingredient page$/) do
  expect(page).to have_css('form')
  expect(page).to have_content('Ingredient')
end

When(/^I fill out Ingredient form with:$/) do |table|
  fill_in "ingredient_name", with: table.hashes[0]["name"]
  fill_in "ingredient_price", with: table.hashes[0]["price"]
  fill_in "ingredient_measure", with: table.hashes[0]["measure"]
  select table.hashes[0]["unit"], from: "ingredient_unit"
  select table.hashes[0]["ingredient_type"], from: "ingredient_ingredient_type"
  fill_in "ingredient_description", with: table.hashes[0]["description"]
end

Then(/^I should be redirected to the Ingredients page$/) do
  expect(page).to have_content("Ingredients")
end

Given(/^I am on the edit page for "(.*?)" ingredient$/) do |name|
  ingredient = Ingredient.find_by(name: name)
  visit edit_ingredient_path(ingredient)
end

When(/^I change the ingredient name to "(.*?)"$/) do |name|
  fill_in "ingredient_name", with: name
end

Then(/^I should see that the ingredient name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end
