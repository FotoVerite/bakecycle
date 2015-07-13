When(/^I fill out Bakery form with:$/) do |table|
  fill_in 'bakery_name', with: table.hashes[0]['name']
  fill_in 'bakery_email', with: table.hashes[0]['email']
  fill_in 'bakery_phone_number', with: table.hashes[0]['phone']
  fill_in 'bakery_address_street_1', with: table.hashes[0]['street']
  fill_in 'bakery_address_city', with: table.hashes[0]['city']
  fill_in 'bakery_address_state', with: table.hashes[0]['state']
  fill_in 'bakery_address_zipcode', with: table.hashes[0]['zipcode']
end

Then(/^"(.*?)" bakery should have demodata in the database$/) do |name|
  bakery = Bakery.find_by(name: name)
  expect(bakery.products.count).to be > 5
end
