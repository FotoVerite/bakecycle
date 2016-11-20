Given(/^There are "(.*?)" bakery clients named "(.*?)" and "(.*?)"$/) do |bakery, name1, name2|
  bakery = Bakery.find_by(name: bakery)
  create(:client, name: name1, bakery: bakery)
  create(:client, name: name2, bakery: bakery)
end

Given(/^there is a bakery called "(.*?)"$/) do |name|
  create(:bakery, name: name)
end

Then(/^I should see a list of clients including "(.*?)" and "(.*?)"$/) do |client1, client2|
  expect(page).to have_content(client1)
  expect(page).to have_content(client2)
end

Then(/^I should not see clients "(.*?)" and "(.*?)"$/) do |client1, client2|
  expect(page).to_not have_content(client1)
  expect(page).to_not have_content(client2)
end

When(/^I fill out the client "(.*?)" with valid data$/) do |name|
  fill_in "client_name", with: name
  fill_in "client_official_company_name", with: name
  fill_in "client_business_phone", with: "212-867-5309"
  fill_in "client_delivery_address_street_1", with: "text"
  fill_in "client_delivery_address_street_2", with: "text"
  fill_in "client_delivery_address_city", with: "text"
  fill_in "client_delivery_address_state", with: "text"
  fill_in "client_delivery_address_zipcode", with: "text"
  fill_in "client_billing_address_street_1", with: "text"
  fill_in "client_billing_address_street_2", with: "text"
  fill_in "client_billing_address_city", with: "text"
  fill_in "client_billing_address_state", with: "text"
  fill_in "client_billing_address_zipcode", with: "text"
  fill_in "client_accounts_payable_contact_name", with: "text"
  fill_in "client_accounts_payable_contact_phone", with: "text"
  fill_in "client_accounts_payable_contact_email", with: "text@email.com"
  fill_in "client_primary_contact_name", with: "text"
  fill_in "client_primary_contact_phone", with: "text"
  fill_in "client_primary_contact_email", with: "text@email.com"
  fill_in "client_secondary_contact_name", with: "text"
  fill_in "client_secondary_contact_phone", with: "text"
  fill_in "client_secondary_contact_email", with: "text@email.com"
  choose "client_active_true"
  select "Credit Card", from: "client_billing_term"
  select "Daily Delivery Fee", from: "client_delivery_fee_option"
  fill_in "client_delivery_minimum", with: "310.00"
  fill_in "client_delivery_fee", with: "20.85"
  fill_in "client_notes", with: "Call before knocking"
end

Then(/^the client "(.*?)" should not be present$/) do |client_name|
  within ".responsive-table" do
    expect(page).to_not have_content(client_name)
  end
end

When(/^I am on the edit page for the client "(.*?)"$/) do |name|
  client = Client.find_by(name: name)
  visit edit_client_path(client)
end

When(/^I attempt to visit "(.*?)" edit page$/) do |name|
  client = Client.find_by(name: name)
  visit edit_client_path(client)
end

When(/^I change the client name to "(.*?)"$/) do |name|
  fill_in "client_name", with: name
end

When(/^I am on the view page for "(.*?)"$/) do |name|
  client = Client.find_by(name: name)
  visit client_path(client)
end

Given(/^That there's shipments for "(.*?)" and "(.*?)"$/) do |name1, name2|
  client1 = Client.find_by(name: name1)
  client2 = Client.find_by(name: name2)
  create(:shipment, client: client1, bakery: client1.bakery)
  create(:shipment, client: client2, bakery: client2.bakery)
end

Then(/^I should see recent shipments information$/) do
  expect(page).to have_css(".recent-shipment")
end

Then(/^I should be on the shipment's index page with "(.*?)" shipments and none from "(.*?)"$/) do |name1, name2|
  within ".responsive-table" do
    expect(page).to have_content(name1)
    expect(page).to_not have_content(name2)
  end
end

Then(/^The client "(.*?)" should not be present$/) do |client|
  within ".responsive-table" do
    expect(page).to_not have_content(client)
  end
end

Then(/^I should see confirmation that the client "(.*?)" was deleted$/) do |client|
  within ".alert-box" do
    expect(page).to have_content("You have deleted #{client}")
  end
end

Given(/^That there's orders for "(.*?)" and "(.*?)"$/) do |name1, name2|
  client1 = Client.find_by(name: name1)
  client2 = Client.find_by(name: name2)
  bakery = client1.bakery
  route = create(:route, bakery: bakery)
  create(:order, client: client1, bakery: bakery, route: route)
  create(:order, client: client1, bakery: bakery, route: route, order_type: "temporary")
  create(:order, client: client2, bakery: bakery, route: route)
  create(:order, client: client2, bakery: bakery, route: route, order_type: "temporary")
end

Then(/^I should see upcoming orders information$/) do
  expect(page).to have_css(".upcoming-orders")
end

Then(/^I should be on the orders index page with "(.*?)" shipments and none from "(.*?)"$/) do |name1, name2|
  within ".order-index-table" do
    expect(page).to have_content(name1)
    expect(page).to_not have_content(name2)
  end
end
