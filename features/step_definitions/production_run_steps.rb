Given(/^there is a "(.*?)" production run$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  create(:production_run, bakery: bakery, date: Date.today)
end

Then(/^I should see production runs for "(.*?)"$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  production_run = bakery.production_runs.first
  expect(page).to have_content("#{production_run.id}: #{production_run.date}")
end

Given(/^there is a run item for a "(.*?)" production run$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  create(:run_item, production_run: bakery.production_runs.last, product: bakery.products.first)
end

When(/^I fill out run item form with:$/) do |table|
  all(:xpath, '//select').last.find(:xpath, "option[text()='#{table.hashes[0]['product']}']").click
  all('.new_run_item_overbake_quantity').last.set(table.hashes[0]['overbake_quantity'])
end

When(/^I change the overbake quantity on the existing run item$/) do
  fill_in('Overbake quantity', with: 33)
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
  expect(page).to have_content(Date.today)
end
