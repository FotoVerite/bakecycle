Given(/^There are "(.*?)" bakery routes named "(.*?)" and "(.*?)"$/) do |bakery, route1, route2|
  bakery = Bakery.find_by(name: bakery)
  create(:route, name: route1, bakery: bakery)
  create(:route, name: route2, bakery: bakery)
end

Then(/^I should see a list of routes including "(.*?)" and "(.*?)"$/) do |route1, route2|
  within '.responsive-table' do
    expect(page).to have_content(route1)
    expect(page).to have_content(route2)
  end
end

When(/^I fill out Route form with:$/) do |table|
  fill_in 'route_name', with: table.hashes[0]['name']
  fill_in 'route_notes', with: table.hashes[0]['notes']
  fill_in 'route_departure_time', with: table.hashes[0]['time']
  choose "route_active_#{table.hashes[0]['active']}"
end

When(/^I am on the edit page for "(.*?)" route$/) do |name|
  route = Route.find_by(name: name)
  visit edit_route_path(route)
end

When(/^I change the route name to "(.*?)"$/) do |name|
  fill_in 'route_name', with: name
end

Then(/^I should see that the route name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

Then(/^The route "(.*?)" should not be present$/) do |client|
  within '.responsive-table' do
    expect(page).to_not have_content(client)
  end
end

Then(/^I should see confirmation that the route "(.*?)" was deleted$/) do |client|
  within '.alert-box' do
    expect(page).to have_content("You have deleted #{client}")
  end
end
