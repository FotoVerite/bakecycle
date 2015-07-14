Given(/^I am on the Batch Recipes Page$/) do
  visit batch_recipes_path
end

Then(/^I should see the csv$/) do
  expect(page).to have_content 'Product'
  expect(page).to have_content 'Total Quantity'
  expect(page).to have_content 'Order Quantity'
  expect(page).to have_content 'Over Bake %'
  expect(page).to have_content 'Over Bake Quantity'
end
