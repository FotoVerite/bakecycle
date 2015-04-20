Given(/^There are "(.*?)" shipments with clients named "(.*?)" and "(.*?)"$/) do |bakery, name1, name2|
  bakery = Bakery.find_by(name: bakery)

  client1 = create(:client, name: name1, bakery: bakery)
  client2 = create(:client, name: name2, bakery: bakery)

  create(:shipment, client: client1, bakery: bakery)
  create(:shipment, client: client2, bakery: bakery)
end

When(/^I fill out Shipment form with:$/) do |table|
  fill_in 'shipment_date', with: table.hashes[0]['date']
  select table.hashes[0]['route'], from: 'shipment_route_id'
  select table.hashes[0]['client'], from: 'shipment_client_id'
  fill_in 'shipment_delivery_fee', with: table.hashes[0]['delivery_fee']
  fill_in 'shipment_note', with: table.hashes[0]['note']
end

When(/^I am on the shipment edit page for the client "(.*?)"$/) do |name|
  client = Client.find_by(name: name)
  shipment = Shipment.find_by(client_id: client)
  visit edit_shipment_path(shipment)
end

When(/^I change the shipment's client name to "(.*?)"$/) do |name|
  select name, from: 'shipment_client_id'
end

Then(/^I should see that the shipment's client name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I change the shipment date to "(.*?)"$/) do |date|
  fill_in 'shipment_date', with: date
end

When(/^I fill out Shipment Item form with:$/) do |table|
  all(:xpath, '//select').last.find(:xpath, "option[text()='#{table.hashes[0]['product']}']").click
  all('.product_quantity_input').last.set(table.hashes[0]['quantity'])
  all('.product_price_input').last.set(table.hashes[0]['product_price'])
end

When(/^I am on the edit page for "(.*?)" shipment$/) do |name|
  client = Client.find_by(name: name)
  shipment = Shipment.find_by(client_id: client)
  visit edit_shipment_path(shipment)
end

When(/^I replace "(.*?)" product name with "(.*?)"$/) do |_, name|
  all(:xpath, '//select').last.find(:xpath, "option[text()='#{name}']").click
end

Then(/^the shipment item "(.*?)" should be present$/) do |name|
  find(:xpath, "//select/option[@selected='selected' and text()='#{name}']")
end

Then(/^the shipment item "(.*?)" should not be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to raise_error
end

When(/^I delete "(.*?)" shipment item$/) do |name|
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../..")
  form.find('a', text: 'X').click
end

When(/^I filter shipments by the client "(.*?)"$/) do |client_name|
  select client_name, from: 'search[client_id]'
  click_button 'Search'
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

Given(/^there are "(.*?)" shipments for the past two weeks$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  today = Time.zone.today
  create(:shipment, bakery: bakery, date: today)
  create(:shipment, bakery: bakery, date: today - 2.days)
  create(:shipment, bakery: bakery, date: today - 5.days)
  create(:shipment, bakery: bakery, date: today - 7.days)
  create(:shipment, bakery: bakery, date: today - 10.days)
  create(:shipment, bakery: bakery, date: today - 11.days)
  create(:shipment, bakery: bakery, date: today - 15.days)
end

When(/^I filter shipments by to and from dates for the past week$/) do
  fill_in 'search_date_from', with: (Time.zone.today - 7.days).to_s
  fill_in 'search_date_to', with: (Time.zone.today).to_s
  click_button 'Search'
end

Then(/^I should see a list of shipments for only the past week$/) do
  within '.responsive-table' do
    today = Time.zone.today
    expect(page).to have_content(today.strftime('%Y-%m-%d'))
    expect(page).to have_content((today - 2.days).strftime('%Y-%m-%d'))
    expect(page).to have_content((today - 5.days).strftime('%Y-%m-%d'))
    expect(page).to have_content((today - 7.days).strftime('%Y-%m-%d'))
    expect(page).to_not have_content((today - 10.days).strftime('%Y-%m-%d'))
    expect(page).to_not have_content((today - 11.days).strftime('%Y-%m-%d'))
    expect(page).to_not have_content((today - 15.days).strftime('%Y-%m-%d'))
  end
end

Then(/^I should see the search term "(.*?)" preserved in the client search box$/) do |client|
  find(:xpath, "//select/option[@selected='selected' and text()='#{client}']")
end

Given(/^There are "(.*?)" shipments for "(.*?)"$/) do |number, name|
  client = Client.find_by(name: name)
  create_list(:shipment, number.to_i, client: client, bakery: client.bakery)
end

Then(/^I should see shipments for "(.*?)"$/) do |name|
  within '.responsive-table' do
    expect(page).to have_content(name)
  end
end

Then(/^I should see confirmation the shipment for "(.*?)" was deleted$/) do |shipment|
  within '.alert-box' do
    expect(page).to have_content("You have deleted the shipment for #{shipment}")
  end
end

Then(/^the shipment for "(.*?)" should not be present$/) do |shipment|
  within '.responsive-table' do
    expect(page).to_not have_content(shipment)
  end
end
