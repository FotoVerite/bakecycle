Given(/^there are bakeries named "(.*?)","(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  create(:bakery, name: name1)
  create(:bakery, name: name2)
  create(:bakery, name: name3)
end

Given(/^there is a bakery named "(.*?)"$/) do |name|
  create(:bakery, name: name)
end

Then(/^I should see a list of bakeries including "(.*?)", "(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  within ".responsive-table" do
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
  fill_in "bakery_name", with: name
end

Then(/^I should see that the bakery name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out Bakery form with valid data$/) do
  fill_in "bakery_name", with: "Au Bon Pain"
  select "Small Bakery", from: "bakery_plan_id"
end

Then(/^I should see confirmation the bakery was deleted$/) do
  within ".alert-box" do
    expect(page).to have_content("You have deleted")
  end
end

Then(/^the bakery "(.*?)" should not be present$/) do |bakery_name|
  within ".responsive-table" do
    expect(page).to_not have_content(bakery_name)
  end
end

When(/^I upload my Bakery logo$/) do
  field = :bakery_logo
  path = File.join(Rails.root, "app/assets/images/example_logo.png")
  attach_file(field, path)
end

When(/^I visit my bakery$/) do
  visit my_bakeries_path
end

Then(/^"(.*?)" link should not be present$/) do |name|
  has_no_link?(name)
end

Then(/^"(.*?)" button should be present$/) do |name|
  has_button?(name)
end

Then(/^"(.*?)" button should not be present$/) do |name|
  has_no_button?(name)
end

Given(/^I am logged in as a user with bakery "(.*?)" access with a bakery called "(.*?)"$/) do |access, name|
  bakery = create(:bakery, name: name)
  user = create(:user, bakery: bakery, bakery_permission: access)
  login_as(user, scope: :user)
end
