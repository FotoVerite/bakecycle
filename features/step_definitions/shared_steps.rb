Given(/^I am a visitor$/) do
  logout(:user)
end

When(/^I logout$/) do
  find('.logout-icon').click
end

When(/^I pry$/) do
  # rubocop:disable Lint/Debugger
  binding.pry
  # rubocop:enable Lint/Debugger
end

When(/^I confirm popup$/) do
  confirm_alert
end

When(/^I click on "(.*?)"$/) do |linkable_text|
  click_on(linkable_text, match: :first)
end

Then(/^"(.*?)" should not be present$/) do |content|
  expect(page).to_not have_content(content)
end

Then(/^"(.*?)" should be present$/) do |content|
  expect(page).to have_content(content)
end

Then(/^I should be on the "(.*?)" index page$/) do |model|
  expect(page).to have_content(model)
end

When(/^I go to the home page$/) do
  visit root_path
end

Given(/^I am logged in as a user$/) do
  bakery = Bakery.first || create(:bakery)
  user = create(:user, bakery: bakery)
  login_as(user, scope: :user)
end

Given(/^I am logged in as an admin$/) do
  user = create(:user, :as_admin, bakery: nil)
  login_as(user, scope: :user)
end

Given(/^I am logged in as a user with a bakery called "(.*?)"$/) do |name|
  bakery = create(:bakery, name: name)
  user = create(:user, bakery: bakery)
  login_as(user, scope: :user)
end

When(/^I go to the "(.*?)" page$/) do |page|
  path_string = "#{page}_path"
  visit send(path_string.to_sym)
end

Given(/^I am on the "(.*?)" page$/) do |page|
  path_string = "#{page}_path"
  visit send(path_string.to_sym)
end

Then(/^"(.*?)" page header should be present$/) do |page_header|
  expect(page).to have_selector('h1', text: page_header)
end

Then(/^"(.*?)" should be present "(.*?)" times$/) do |keyword, count|
  regexp = Regexp.new(keyword)
  count = count.to_i
  page.find(:xpath, '//body').text.split(regexp).length.should == count + 1
end

Then(/^I should see "(.*?)" information about "(.*?)"$/) do |object, name|
  expect(page).to have_content("#{object}: #{name}")
end

Given(/^I click on "(.*?)" and don't enter any information$/) do |linkable_text|
  click_on(linkable_text, match: :first)
end
