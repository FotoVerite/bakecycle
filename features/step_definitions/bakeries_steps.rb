Given(/^There are bakeries named "(.*?)","(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  create(:bakery, :with_logo, name: name1)
  create(:bakery, :with_logo, name: name2)
  create(:bakery, :with_logo, name: name3)
end

Then(/^I should see a list of bakeries including "(.*?)", "(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  within '.responsive-table' do
    expect(page).to have_content(name1)
    expect(page).to have_content(name2)
    expect(page).to have_content(name3)
  end
end

Given(/^I am on the edit page for "(.*?)" bakery$/) do |name|
  bakery = Bakery.find_by(name: name)
  visit edit_bakery_path(bakery)
end

When(/^I change the bakery name to "(.*?)"$/) do |name|
  fill_in 'bakery_name', with: name
end

Then(/^I should see that the bakery name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out Bakery form with valid data$/) do
  fill_in 'bakery_name', with: 'Au Bon Pain'
  fill_in 'bakery_email', with: 'test@example.com'
  fill_in 'bakery_phone_number', with: '999-888-7777'
  fill_in 'bakery_address_street_1', with: '123 Example St.'
  fill_in 'bakery_address_city', with: 'Bake'
  fill_in 'bakery_address_state', with: 'NY'
  fill_in 'bakery_address_zipcode', with: '10001'
  fill_in 'bakery_kickoff_time', with: '3:00PM'
  fill_in 'bakery_quickbooks_account', with: 'Sales:Sales - Wholesale'
end

Then(/^I should see confirmation the bakery was deleted$/) do
  within '.alert-box' do
    expect(page).to have_content('You have deleted')
  end
end

Then(/^the bakery "(.*?)" should not be present$/) do |bakery_name|
  within '.responsive-table' do
    expect(page).to_not have_content(bakery_name)
  end
end

When(/^I upload my Bakery logo$/) do
  field = :bakery_logo
  path = File.join(Rails.root, 'app/assets/images/example_logo.png')
  attach_file(field, path)
end

Given(/^I go to the "(.*?)" edit bakery page$/) do |name|
  bakery = Bakery.find_by(name: name)
  visit edit_bakery_path(bakery)
end
