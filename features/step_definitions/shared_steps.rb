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
