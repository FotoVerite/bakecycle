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
  fill_in 'recipe_name', with: table.hashes[0]['name']
  fill_in 'recipe_mix_size', with: table.hashes[0]['mix_size']
  select table.hashes[0]['mix_size_unit'], from: 'recipe_mix_size_unit'
  fill_in 'recipe_lead_days', with: table.hashes[0]['lead_days']
  select table.hashes[0]['recipe_type'], from: 'recipe_recipe_type'
  fill_in 'recipe_note', with: table.hashes[0]['note']
end

When(/^I change the recipe name to "(.*?)"$/) do |name|
  fill_in 'recipe_name', with: name
end

Then(/^I should see that the recipe name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out recipe item with:$/) do |table|
  all(:xpath, '//select').last.find(:xpath, "option[text()='#{table.hashes[0]['inclusionable_id_type']}']").click
  all('input[type=text]').last.set(table.hashes[0]['percentage'])
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
