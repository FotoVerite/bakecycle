Given(/^There are "(.*?)" bakery products named "(.*?)" and "(.*?)"$/) do |bakery, product1, product2|
  bakery = Bakery.find_by(name: bakery)
  create(:product, name: product1, bakery: bakery)
  create(:product, name: product2, bakery: bakery)
end

Then(/^I should see a list of products including "(.*?)" and "(.*?)"$/) do |product1, product2|
  within '.responsive-table' do
    expect(page).to have_content(product1)
    expect(page).to have_content(product2)
  end
end

When(/^I fill out product form with:$/) do |table|
  row = table.hashes.first
  jquery_fill(
    '#product_name' => row['name'],
    '#product_sku' => row['sku'],
    '#product_base_price' => row['base_price'],
    '#product_weight' => row['weight'],
    '#product_over_bake' => row['over_bake'],
    '#product_description' => row['description'],
    '#product_product_type' => row['product_type'],
    '#product_unit' => row['unit']
  )
end

When(/^I change the product name to "(.*?)"$/) do |name|
  fill_in 'product_name', with: name
end

Then(/^I should see that the product name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
end

When(/^I fill out the price varient form with:$/) do |table|
  pricev = table.hashes[0]
  jquery_fill(
    '.price_input:last' => pricev['price'],
    '.quantity_input:last' => pricev['quantity']
  )
end

Then(/^I click on the last price's remove button$/) do
  all('.remove-button').last.click
end

Then(/^I edit the remaining price to "(.*?)"$/) do |price|
  all('.price_input').last.set(price)
end

Then(/^there should only be one price$/) do
  all('.price_input').count == 1
end

Then(/^I should see confirmation that the product "(.*?)" was deleted$/) do |product|
  within '.alert-box' do
    expect(page).to have_content("You have deleted #{product}")
  end
end

Then(/^The product "(.*?)" should not be present$/) do |product|
  within '.responsive-table' do
    expect(page).to_not have_content(product)
  end
end
