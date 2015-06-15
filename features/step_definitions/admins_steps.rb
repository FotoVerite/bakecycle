When(/^I fill out User with bakery form with:$/) do |table|
  fill_in 'user_email', with: table.hashes[0]['email']
  fill_in 'user_name', with: table.hashes[0]['name']
  fill_in 'user_password', with: table.hashes[0]['password']
  fill_in 'user_password_confirmation', with: table.hashes[0]['password_confirmation']
  select table.hashes[0]['bakery'], from: 'user_bakery_id'
end

Then(/^I should see a bakeries column$/) do
  find('.responsive-table').should have_content('Bakery')
end
