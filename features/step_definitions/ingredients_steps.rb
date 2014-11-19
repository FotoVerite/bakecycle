Given(/^There are ingredients named "(.*?)","(.*?)" and "(.*?)"$/) do |arg1, arg2, arg3|
  FactoryGirl.create(:ingredient, name: arg1)
  FactoryGirl.create(:ingredient, name: arg2)
  FactoryGirl.create(:ingredient, name: arg3)
end

When(/^I go to the ingredients page$/) do
  visit ingredients_path
end

Then(/^I should see a list of ingredients including "(.*?)", "(.*?)" and "(.*?)"$/) do |arg1, arg2, arg3|
  expect(page).to have_content(arg1)
  expect(page).to have_content(arg2)
  expect(page).to have_content(arg3)
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
  click_on "Create"
end

Then(/^I should be redirected to the Ingredients page$/) do
  expect(page).to have_content("Ingredients")
end

Given(/^I am on the edit page for "(.*?)" ingredient$/) do |arg1|
  ingredient = Ingredient.find_by(name: arg1)
  visit edit_ingredient_path(ingredient)
end

When(/^I change the ingredient name to "(.*?)"$/) do |arg1|
  fill_in "ingredient_name", with: arg1
end

Then(/^I should see that the ingredient name is "(.*?)"$/) do |arg1|
  expect(page).to have_content(arg1)
end
