Given(/^There are recipes named "(.*?)","(.*?)" and "(.*?)"$/) do |arg1, arg2, arg3|
  FactoryGirl.create(:recipe, name: arg1)
  FactoryGirl.create(:recipe, name: arg2)
  FactoryGirl.create(:recipe, name: arg3)
end

When(/^I go to the recipes page$/) do
  visit recipes_path
end

Then(/^I should see a list of recipes including "(.*?)", "(.*?)" and "(.*?)"$/) do |arg1, arg2, arg3|
  expect(page).to have_content(arg1)
  expect(page).to have_content(arg2)
  expect(page).to have_content(arg3)
end

Then(/^I should be redirected to an recipe page$/) do
  expect(page).to have_css('form')
  expect(page).to have_content('Recipe')
end

When(/^I fill out recipe form with:$/) do |table|
  fill_in "recipe_name", with: table.hashes[0]["name"]
  fill_in "recipe_mix_size", with: table.hashes[0]["mix_size"]
  select table.hashes[0]["mix_size_unit"], from: "recipe_mix_size_unit"
  fill_in "recipe_lead_days", with: table.hashes[0]["lead_days"]
  select table.hashes[0]["recipe_type"], from: "recipe_recipe_type"
  fill_in "recipe_note", with: table.hashes[0]["note"]
end

Then(/^I should be redirected to the recipes page$/) do
  expect(page).to have_content("Recipes")
end

Given(/^I am on the edit page for "(.*?)" recipe$/) do |arg1|
  recipe = Recipe.find_by(name: arg1)
  visit edit_recipe_path(recipe)
end

When(/^I change the recipe name to "(.*?)"$/) do |arg1|
  fill_in "recipe_name", with: arg1
end

Then(/^I should see that the recipe name is "(.*?)"$/) do |arg1|
  expect(page).to have_content(arg1)
end

When(/^I fill out recipe item with:$/) do |table|
  all(:xpath, "//select").last.find(:xpath, "option[text()='#{table.hashes[0]["inclusionable_id_type" ]}']").click
  all("input[type=text]").last.set(table.hashes[0]["percentage"])
end

When(/^I fill out a second recipe item with:$/) do |table|
  all(:xpath, "//select").last.find(:xpath, "option[text()='#{table.hashes[0]["inclusionable_id_type" ]}']").click
  all("input[type=text]").last.set(table.hashes[0]["percentage"])
end

When(/^I delete "(.*?)" ingredient$/) do |name|
  find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../..").find('a', text:"Remove").click
end

When(/^I edit "(.*?)" baker's percentage$/) do |name|
  find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../..").find_field("Baker\'s %").set("10.5")
end

Then(/^the recipe item "(.*?)" should be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to_not raise_error
end

Then(/^the recipe item "(.*?)" should not be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to raise_error
end
