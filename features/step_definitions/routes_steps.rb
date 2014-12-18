Given(/^There are routes named "(.*?)","(.*?)" and "(.*?)"$/) do |route1, route2, route3|
  create(:route, name: route1)
  create(:route, name: route2)
  create(:route, name: route3)
end

Then(/^I should see a list of routes including "(.*?)", "(.*?)" and "(.*?)"$/) do |route1, route2, route3|
  expect(page).to have_content(route1)
  expect(page).to have_content(route2)
  expect(page).to have_content(route3)
end

Then(/^I should be redirected to a route page$/) do
  expect(page).to have_css('form')
  expect(page).to have_content('Route')
end

When(/^I fill out Route form with:$/) do |table|
  fill_in "route_name", with: table.hashes[0]["name"]
  fill_in "route_notes", with: table.hashes[0]["notes"]
  fill_in "route_departure_time", with: table.hashes[0]["time"]
  choose "route_active_#{table.hashes[0]['active']}"
end

When(/^I am on the edit page for "(.*?)" route$/) do |name|
  route = Route.find_by(name: name)
  visit edit_route_path(route)
end

Then(/^I should be redirected to the Routes page$/) do
  expect(page).to have_content("Routes")
end

When(/^I change the route name to "(.*?)"$/) do |name|
  fill_in "route_name", with: name
end

Then(/^I should see that the route name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end
