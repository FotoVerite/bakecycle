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
  fill_in "shipment_shipment_date", with: table.hashes[0]["shipment_date"]
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
  fill_in "shipment_shipment_date", with: date
end

When(/^I fill out Shipment Item form with:$/) do |table|
  all(:xpath, "//select").last.find(:xpath, "option[text()='#{table.hashes[0]['product']}']").click
  all('.product_quantity_input').last.set(table.hashes[0]["quantity"])
  all('.price_per_item_input').last.set(table.hashes[0]["price_per_item"])
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
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to_not raise_error
end

Then(/^the shipment item "(.*?)" should not be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to raise_error
end

When(/^I delete "(.*?)" shipment item$/) do |name|
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../..")
  form.find('a', text: "X").click
end
