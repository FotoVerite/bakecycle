Given(/^I am a visitor$/) do
  logout(:user)
end

Given(/^There exists a user$/) do
  @user = FactoryGirl.create(:user)
end

When(/^I logout$/) do
  find(".logout-icon").click
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

When(/^I click on the "(.*?)" link$/) do |name|
  all("a", text: name).first.click
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

When(/^I go to the dashboard$/) do
  visit dashboard_path
end

Given(/^I am logged in as a user$/) do
  bakery = Bakery.first || create(:bakery)
  user = create(:user, bakery: bakery)
  login_as(user, scope: :user)
end

Given(/^I am logged in as an user with product "(.*?)" access with a bakery called "(.*?)"$/) do |access, name|
  bakery = create(:bakery, name: name)
  user = create(:user, bakery: bakery, product_permission: access)
  login_as(user, scope: :user)
end

Given(/^I am logged in as an user with client "(.*?)" access with a bakery called "(.*?)"$/) do |access, name|
  bakery = create(:bakery, name: name)
  user = create(:user, bakery: bakery, client_permission: access)
  login_as(user, scope: :user)
end

Given(/^I am logged in as an user with shipping "(.*?)" access with a bakery called "(.*?)"$/) do |access, name|
  bakery = create(:bakery, name: name)
  user = create(:user, bakery: bakery, shipping_permission: access)
  login_as(user, scope: :user)
end

Given(/^Theres a bakery called "(.*?)"$/) do |name|
  create(:bakery, name: name)
end

Given(/^I am logged in as an user apart of "(.*?)" bakery with shipping "(.*?)" access$/) do |bakery_name, access|
  bakery = Bakery.find_by(name: bakery_name)
  user = create(:user, bakery: bakery, shipping_permission: access)
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

Then(/^"(.*?)" button should be present "(.*?)" times$/) do |button_class, count|
  have_css(".#{button_class}", count: count.to_i)
end

Then(/^I should see "(.*?)" information about "(.*?)"$/) do |object, name|
  expect(page).to have_content("#{object}: #{name}")
end

Then(/^I should see the pdf generated page with "(.*?)" included in the url$/) do |pdf_name|
  page.within_window(page.windows.last) do
    current_url.include?(pdf_name)
  end
end

Then(/^"(.*?)" link should not be on the side nav$/) do |link|
  within ".side-navigation" do
    page.has_no_link?(link)
  end
end
