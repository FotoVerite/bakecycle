Given(/^There are clients named "(.*?)","(.*?)" and "(.*?)"$/) do |client1, client2, client3|
  create(:client, name: client1)
  create(:client, name: client2)
  create(:client, name: client3)
end

Then(/^I should see a list of clients including "(.*?)", "(.*?)" and "(.*?)"$/) do |client1, client2, client3|
  expect(page).to have_content(client1)
  expect(page).to have_content(client2)
  expect(page).to have_content(client3)
end

Then(/^I should be redirected to a client page with the name "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out Client form with valid data$/) do
  fill_in "client_name", with: "Test"
  fill_in "client_dba", with: "text"
  fill_in "client_business_phone", with: "text"
  fill_in "client_business_fax", with: "text"
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
end

Then(/^I should be redirected to the Clients page$/) do
  visit clients_path
end

When(/^I am on the edit page for "(.*?)" client$/) do |name|
  client = Client.find_by(name: name)
  visit edit_client_path(client)
end

When(/^I change the client name to "(.*?)"$/) do |name|
  fill_in "client_name", with: name
end
