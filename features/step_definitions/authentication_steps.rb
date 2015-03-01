Given(/^There is a user with email "(.*?)" and password "(.*?)"$/) do |email, password|
  create(:user, email: email, password: password, password_confirmation: password)
end

When(/^I fill in user form with:$/) do |table|
  fill_in 'user_email', with: table.hashes[0]['email']
  fill_in 'user_password', with: table.hashes[0]['password']
end
