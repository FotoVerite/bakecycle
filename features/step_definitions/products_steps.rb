When(/^I fill out product form with:$/) do |table|
  fill_in "product_name", with: table.hashes[0]["name"]
  select table.hashes[0]["product_type"], from: "product_product_type"
  fill_in "product_weight", with: table.hashes[0]["weight"]
  select table.hashes[0]["unit"], from: "product_unit"
  fill_in "product_description", with: table.hashes[0]["description"]
  fill_in "product_extra_amount", with: table.hashes[0]["extra_amount"]
  fill_in "product_base_price", with: table.hashes[0]["base_price"]
end

Then(/^I should see a list of products including "(.*?)", "(.*?)" and "(.*?)"$/) do |product1, product2, product3|
  expect(page).to have_content(product1)
  expect(page).to have_content(product2)
  expect(page).to have_content(product3)
end

Then(/^I should be redirected to a product page$/) do
  expect(page).to have_css('form')
  expect(page).to have_content('Product')
end

When(/^I am on the edit page for "(.*?)" product$/) do |name|
  product = Product.find_by(name: name)
  visit edit_product_path(product)
end

When(/^I change the product name to "(.*?)"$/) do |name|
  fill_in "product_name", with: name
end

Then(/^I should see that the product name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

Then(/^I should be redirected to the products page$/) do
  expect(page).to have_content("Products")
end

When(/^I fill out the price varient form with:$/) do |table|
  all('.price_input').last.set(table.hashes[0]["price"])
  all('.quantity_input').last.set(table.hashes[0]["quantity"])
  all('.js-datepicker').last.set(table.hashes[0]["date"])
end

Then(/^I click on the last price's remove button$/) do
  all('.remove_price_varient').last.click
end

Then(/^I edit the remaining price to "(.*?)"$/) do |price|
  all('.price_input').last.set(price)
end

Then(/^there should only be one price$/) do
  all('.price_input').count == 1
end
