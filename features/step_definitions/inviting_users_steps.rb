Given(/^There exists a user with an unaccepted invitation$/) do
  @user = create(:user, invitation_token: 'something')
end

When(/^I fill out the user with a bakery selection form with:$/) do |table|
  fill_in 'user_email', with: table.hashes[0]['email']
  fill_in 'user_name', with: table.hashes[0]['name']
  if table.hashes[0]['bakery']
    select table.hashes[0]['bakery'], from: 'user_bakery_id'
  end
  if table.hashes[0]['password'].present?
    fill_in 'user_password', with: table.hashes[0]['password']
    fill_in 'user_password_confirmation', with: table.hashes[0]['password_confirmation']
  end
end

Then(/^There should not be an email sent to the new user$/) do
  open_email('helloworld@example.com')
  expect(current_email).to eq nil
end

When(/^I send a confirmation email$/) do
  link = find("a[href='#{send_user_invitation_path(@user)}']")
  link.click
end

Then(/^I should not see the link to send a confirmation email$/) do
  link = "a[href='#{send_user_invitation_path(@user)}']"
  expect(page).to_not have_link link
end

Then(/^There should be an email to confirm the account$/) do
  @user ||= User.last
  open_email(@user.email)
  expect(current_email).to have_content "Hello #{@user.email} Someone has invited you"
end
