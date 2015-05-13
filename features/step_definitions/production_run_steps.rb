Given(/^there is a "(.*?)" production run$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  create(:production_run, bakery: bakery, date: Time.zone.today)
end

Given(/^there is a run item for a "(.*?)" production run$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  create(:run_item, production_run_id: bakery.production_runs.last.id, product: bakery.products.first)
end

When(/^I fill out run item form with:$/) do |table|
  pr = table.hashes[0]
  jquery_fill(
    '.new_run_item_overbake_quantity:last' => pr['overbake_quantity'],
    'select:last' => pr['product']
  )
end

When(/^I change the overbake quantity on the existing run item$/) do
  jquery_fill(
    '#production_run_run_items_attributes_0_overbake_quantity' => 33
  )
end

When(/^I click an a run item delete button on the donut$/) do
  product = Product.find_by(name: 'donut tart')
  run_item = RunItem.find_by(product: product)
  within("#run_item_#{run_item.id}") do
    click_on 'X'
  end
end

Given(/^I am on the Print Recipes page$/) do
  visit print_recipes_path
end

When(/^I click on that production run row$/) do
  production_run_id = ProductionRun.last.id
  find("#production_run_#{production_run_id}").click
end

Given(/^I am on the Production Runs page$/) do
  visit production_runs_path
end

Then(/^I should see the date for my production run$/) do
  expect(page).to have_content(Time.zone.today)
end

Given(/^"(.*?)" has clients and active orders$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  client = create(:client, bakery: bakery)
  create(:order, :active, bakery: bakery, client: client, order_item_count: 1)
end

When(/^I search for tomorrow's recipe runs$/) do
  formatted_date = (Time.zone.now + 1.day).strftime('%m-%d-%Y')
  fill_in 'search_date', with: formatted_date
  click_on 'Search'
end

Then(/^I should see a warning that I am seeing a projection$/) do
  expect(page).to have_content('Projection')
end

Then(/^I should rows of projected product quantities$/) do
  expect(page.all('.production-run-projection tr').count).to eq(2)
end

When(/^I cancel in the confirm box$/) do
  binding.pry
  page.execute_script 'window.confirm = function () { return false }'
end

When(/^I accept in the confirm box$/) do
  page.execute_script 'window.confirm = function () { return true }'
end
