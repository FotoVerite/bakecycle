Given(/^There are shipments with clients named "(.*?)","(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  client1 = create(:client, name: name1)
  client2 = create(:client, name: name2)
  client3 = create(:client, name: name3)
  create(:shipment, client: client1)
  create(:shipment, client: client2)
  create(:shipment, client: client3)
end

Then(/^I should see a list of shipments including clients named "(.*?)","(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  expect(page).to have_content(name1)
  expect(page).to have_content(name2)
  expect(page).to have_content(name3)
end

When(/^I fill out Shipment form with:$/) do |table|
  fill_in "shipment_date", with: table.hashes[0]["date"]
  select table.hashes[0]["route"], from: "shipment_route_id"
  select table.hashes[0]["client"], from: "shipment_client_id"
end

When(/^I am on the shipment edit page for the client "(.*?)"$/) do |name|
  client = Client.find_by(name: name)
  shipment = Shipment.find_by(client: client)
  visit edit_shipment_path(shipment)
end

When(/^I change the shipment's client name to "(.*?)"$/) do |name|
  select name, from: "shipment_client_id"
end

Then(/^I should see that the shipment's client name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

Then(/^I should be redirected to the Shipments page$/) do
  expect(page).to have_content("Shipments")
end

When(/^I change the shipment date to "(.*?)"$/) do |date|
  fill_in "shipment_date", with: date
end

When(/^I fill out Shipment Item form with:$/) do |table|
  all(:xpath, "//select").last.find(:xpath, "option[text()='#{table.hashes[0]['product']}']").click
  all('.product_quantity_input').last.set(table.hashes[0]["quantity"])
  all('.product_price_input').last.set(table.hashes[0]["product_price"])
end

When(/^I am on the edit page for "(.*?)" shipment$/) do |name|
  client = Client.find_by(name: name)
  shipment = Shipment.find_by(client_id: client)
  visit edit_shipment_path(shipment)
end

When(/^I replace "(.*?)" product name with "(.*?)"$/) do |_, name|
  all(:xpath, "//select").last.find(:xpath, "option[text()='#{name}']").click
end

Then(/^the shipment item "(.*?)" should be present$/) do |name|
  find(:xpath, "//select/option[@selected='selected' and text()='#{name}']")
end

Then(/^the shipment item "(.*?)" should not be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to raise_error
end

When(/^I delete "(.*?)" shipment item$/) do |name|
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../..")
  form.find('a', text: "X").click
end

When(/^I filter shipments by the client "(.*?)"$/) do |client_name|
  select client_name, from: 'search[client_id]'
  click_button "Search"
end

Then(/^I should see shipments for the client "(.*?)"$/) do |client_name|
  within '.responsive-table' do
    expect(page).to have_content(client_name)
  end
end

Then(/^I should not see shipments for the client "(.*?)"$/) do |client_name|
  within '.responsive-table' do
    expect(page).to_not have_content(client_name)
  end
end

Given(/^there are shipments for the past two weeks$/) do
  create(:shipment, date: (Date.today))
  create(:shipment, date: (Date.today - 2))
  create(:shipment, date: (Date.today - 5))
  create(:shipment, date: (Date.today - 7))
  create(:shipment, date: (Date.today - 10))
  create(:shipment, date: (Date.today - 11))
  create(:shipment, date: (Date.today - 15))
end

When(/^I filter shipments by to and from dates for the past week$/) do
  fill_in "search_date_from", with: (Date.today - 7).to_s
  fill_in "search_date_to", with: (Date.today).to_s
  click_button "Search"
end

Then(/^I should see a list of shipments for only the past week$/) do
  within '.responsive-table' do
    expect(page).to have_content(Date.today.strftime("%Y-%m-%d"))
    expect(page).to have_content((Date.today - 2).strftime("%Y-%m-%d"))
    expect(page).to have_content((Date.today - 5).strftime("%Y-%m-%d"))
    expect(page).to have_content((Date.today - 7).strftime("%Y-%m-%d"))
    expect(page).to_not have_content((Date.today - 10).strftime("%Y-%m-%d"))
    expect(page).to_not have_content((Date.today - 11).strftime("%Y-%m-%d"))
    expect(page).to_not have_content((Date.today - 15).strftime("%Y-%m-%d"))
  end
end

When(/^I fill out shipment search form with$/) do |table|
  fill_in "search_date_from", with: table.hashes[0]["date_from"]
  fill_in "search_date_to", with: table.hashes[0]["date_to"]
end

Then(/^I should see the search term "(.*?)" preserved in the client search box$/) do |client|
  find(:xpath, "//select/option[@selected='selected' and text()='#{client}']")
end
