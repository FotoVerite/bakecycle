Given(/^There are bakeries named "(.*?)","(.*?)" and "(.*?)"\]$/) do |name1, name2, name3|
  create(:bakery, name: name1)
  create(:bakery, name: name2)
  create(:bakery, name: name3)
end

Then(/^I should be redirected to a bakery page$/) do
  visit bakeries_path
end

When(/^I am on the edit page for "(.*?)" bakery$/) do |name|
  bakery = Bakery.find_by(name: name)
  visit edit_bakery_path(bakery)
end

When(/^I change the bakery name to "(.*?)"$/) do |name|
  fill_in "bakery_name", with: name
end

Then(/^I should see that the bakery name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

Then(/^I should be redirected to the Bakeries page$/) do
  expect(page).to have_content("Bakeries")
end

When(/^I fill out Bakery form with:$/) do |table|
  fill_in "bakery_name", with: table.hashes[0]["name"]
end
