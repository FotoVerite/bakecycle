Given(/^There are users named "(.*?)",(.*?)" and they belong to "(.*?)" bakery$/) do |name1, name2, bakery|
  biencuit = Bakery.find_by(name: bakery)
  create(:user, name: name1, bakery: biencuit)
  create(:user, name: name2, bakery: biencuit)
end

Then(/^I should see a list of users including "(.*?)" and "(.*?)"$/) do |name1, name2|
  within '.responsive-table' do
    expect(page).to have_content(name1)
    expect(page).to have_content(name2)
  end
end

Then(/^I should be redirected to an user page$/) do
  expect(page).to have_content('Users')
end

When(/^I fill out User form with:$/) do |table|
  fill_in 'user_email', with: table.hashes[0]['email']
  fill_in 'user_name', with: table.hashes[0]['name']
  fill_in 'user_password', with: table.hashes[0]['password']
  fill_in 'user_password_confirmation', with: table.hashes[0]['password_confirmation']
end

When(/^I am on the edit page for "(.*?)" user$/) do |name|
  user = User.find_by(name: name)
  visit edit_user_path(user)
end

When(/^I change the user name to "(.*?)"$/) do |name|
  fill_in 'user_name', with: name
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
