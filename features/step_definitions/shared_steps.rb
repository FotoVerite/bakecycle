Given(/^I am a visitor$/) do
end

When(/^I pry$/) do
  binding.pry
end

When (/^I confirm popup$/) do
  page.driver.browser.switch_to.alert.accept
end

When (/^I dismiss popup$/) do
  page.driver.browser.switch_to.alert.dismiss
end

When(/^I click on "(.*?)"$/) do |arg1|
  click_on arg1
end

Then(/^"(.*?)" should not be present$/) do |name|
  expect(page).to_not have_content(name)
end

Then(/^"(.*?)" should be present$/) do |arg1|
  expect(page).to have_content(arg1)
end

Then(/^I should be on the "(.*?)" index page$/) do |arg1|
  expect(page).to have_content(arg1)
end
