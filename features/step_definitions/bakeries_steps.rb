Given(/^There are bakeries named "(.*?)","(.*?)" and "(.*?)"\]$/) do |name1, name2, name3|
  create(:bakery, name: name1)
  create(:bakery, name: name2)
  create(:bakery, name: name3)
end

Given(/^I am on the edit page for "(.*?)" bakery$/) do |name|
  bakery = Bakery.find_by(name: name)
  visit edit_bakery_path(bakery)
end

When(/^I change the bakery name to "(.*?)"$/) do |name|
  fill_in "bakery_name", with: name
end

Then(/^I should see that the bakery name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out Bakery form with:$/) do |table|
  fill_in "bakery_name", with: table.hashes[0]["name"]
end

Then(/^I should see confirmation the bakery was deleted$/) do
  within '.alert-box' do
    expect(page).to have_content("You have deleted")
  end
end

Then(/^I should see information about the "(.*?)" bakery$/) do |bakery_name|
  expect(page).to have_content("Bakery: #{bakery_name}")
end

Then(/^the bakery "(.*?)" should not be present$/) do |bakery_name|
  within ".responsive-table" do
    expect(page).to_not have_content(bakery_name)
  end
end
