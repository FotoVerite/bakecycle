Given(/^I am logged in as an user with? (none|read|manage) access$/) do |access_type|
  bakery = Bakery.first || create(:bakery)
  @current_user = create(:user, bakery: bakery, user_permission: access_type)
  login_as(@current_user, scope: :user)
end

Given(/^there is a user named "(.*?)"$/) do |name|
  bakery = Bakery.first || create(:bakery)
  create(:user, name: name, bakery: bakery)
end

Then(/^I should see a list of users including "(.*?)"$/) do |name|
  within '.responsive-table' do
    expect(page).to have_content(name)
  end
end

When(/^I fill out User form with:$/) do |table|
  fill_in 'user_email', with: table.hashes[0]['email']
  fill_in 'user_name', with: table.hashes[0]['name']
  fill_in 'user_password', with: table.hashes[0]['password']
  fill_in 'user_password_confirmation', with: table.hashes[0]['password_confirmation']
  select table.hashes[0]['user_permission'], from: 'user_user_permission'
end

When(/^I edit the user "(.*?)"$/) do |name|
  user = User.find_by!(name: name)
  visit edit_user_path(user.id)
end

When(/^I edit my name to "(.*?)"$/) do |name|
  fill_in 'user_name', with: name
end

When(/^I go to my user's edit page$/) do
  visit edit_user_path(@current_user)
end

When(/^I change the user name to "(.*?)" and his user permission to "(.*?)"$/) do |name, access_level|
  fill_in 'user_name', with: name
  select access_level, from: 'user_user_permission'
end

When(/^I attempt to create a new user$/) do
  visit new_user_path
end

Then(/^I should see that the user name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

Then(/^The user "(.*?)" should not be present$/) do |user|
  within '.responsive-table' do
    expect(page).to_not have_content(user)
  end
end

Then(/^I should see confirmation that the user "(.*?)" was deleted$/) do |user|
  within '.alert-box' do
    expect(page).to have_content("You have deleted #{user}")
  end
end

Then(/^I should information about the user "(.*?)"$/) do |name|
  expect(page).to have_content("Editing User: #{name}")
end

Then(/^I should not see a bakeries column$/) do
  find('.responsive-table').should have_no_content('Bakery')
end
