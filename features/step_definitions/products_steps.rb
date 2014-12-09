When(/^I go to the products page$/) do
  visit products_path
end

When(/^I fill out product form with:$/) do |table|
  fill_in "product_name", with: table.hashes[0]["name"]
  select table.hashes[0]["product_type"], from: "product_product_type"
  fill_in "product_weight", with: table.hashes[0]["weight"]
  select table.hashes[0]["unit"], from: "product_unit"
  fill_in "product_description", with: table.hashes[0]["description"]
  fill_in "product_extra_amount", with: table.hashes[0]["extra_amount"]
end

Then(/^I should see a list of products including "(.*?)", "(.*?)" and "(.*?)"$/) do |arg1, arg2, arg3|
  expect(page).to have_content(arg1)
  expect(page).to have_content(arg2)
  expect(page).to have_content(arg3)
end

Then(/^I should be redirected to a product page$/) do
  expect(page).to have_css('form')
  expect(page).to have_content('Product')
end

Given(/^There are products named "(.*?)","(.*?)" and "(.*?)"$/) do |arg1, arg2, arg3|
  FactoryGirl.create(:product, name: arg1)
  FactoryGirl.create(:product, name: arg2)
  FactoryGirl.create(:product, name: arg3)
end

When(/^I am on the edit page for "(.*?)" product$/) do |arg1|
  product = Product.find_by(name: arg1)
  visit edit_product_path(product)
end

When(/^I change the product name to "(.*?)"$/) do |arg1|
  fill_in "product_name", with: arg1
end

Then(/^I should see that the product name is "(.*?)"$/) do |arg1|
  expect(page).to have_content(arg1)
end

Then(/^I should be redirected to the products page$/) do
  expect(page).to have_content("Products")
end

When(/^I fill out the product price form with:$/) do |table|
  all('.price_input').last.set(table.hashes[0]["price"])
  all('.quantity_input').last.set(table.hashes[0]["quantity"])
  all('.js-datepicker').last.set(table.hashes[0]["date"])
end

When(/^I fill out a second product price form with:$/) do |table|
  all('.price_input').last.set(table.hashes[0]["price"])
  all('.quantity_input').last.set(table.hashes[0]["quantity"])
  all('.js-datepicker').last.set(table.hashes[0]["date"])
end

Then(/^I click on the last price's remove button$/) do
  all('.remove_product_price').last.click
end

Then(/^I edit the remaining price to "(.*?)"$/) do |arg1|
  all('.price_input').last.set(arg1)
end

Then(/^there should only be one price$/) do
  all('.price_input').count == 1
end
