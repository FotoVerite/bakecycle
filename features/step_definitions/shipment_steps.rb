Given(/^There are "(.*?)" shipments with clients named "(.*?)" and "(.*?)"$/) do |bakery, name1, name2|
  bakery = Bakery.find_by(name: bakery)

  client1 = create(:client, name: name1, bakery: bakery)
  client2 = create(:client, name: name2, bakery: bakery)

  create(:shipment, client: client1, bakery: bakery, date: Time.zone.now)
  create(:shipment, client: client2, bakery: bakery)
end

When(/^I fill out Shipment form with:$/) do |table|
  shipment = table.hashes[0]
  jquery_fill(
    '#shipment_route_id' => shipment['route'],
    '#shipment_client_id' => shipment['client'],
    '#shipment_date' => shipment['date'],
    '#shipment_delivery_fee' => shipment['delivery_fee'],
    '#shipment_note' => shipment['note']
  )
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
  shipment = table.hashes[0]
  jquery_fill(
    '.fields .product_quantity_input:last' => shipment['quantity'],
    '.fields .product_price_input:last' => shipment['product_price'],
    '.fields select:last' => shipment['product']
  )
end

Then(/^the product "(.*?)" should be selected$/) do |product_name|
  expect(page).to have_selector(:xpath, "//select/option[@selected='selected' and text()='#{product_name}']")
end

Then(/^the product "(.*?)" should not be selected$/) do |product_name|
  expect(page).to have_no_selector(:xpath, "//select/option[@selected='selected' and text()='#{product_name}']")
end

When(/^I delete "(.*?)" shipment item$/) do |name|
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../..")
  form.find('a', text: 'X').click
end

When(/^I filter shipments by the client "(.*?)"$/) do |client_name|
  find('#search_client_id_chosen').click
  find('.active-result', text: client_name).click
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

Then(/^I attempt to edit the first shipment on the page$/) do
  within '.responsive-table tbody' do
    first('tr').click
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

Then(/^I should see confirmation the shipment for "(.*?)" was deleted$/) do |shipment|
  within '.alert-box' do
    expect(page).to have_content("You have deleted the invoice for #{shipment}")
  end
end

Then(/^the shipment for "(.*?)" should not be present$/) do |shipment|
  within '.responsive-table' do
    expect(page).to_not have_content(shipment)
  end
end

Then(/^I should see a table of shipping information$/) do
  within '.responsive-table' do
    expect(page).to have_content('Client')
  end
end
