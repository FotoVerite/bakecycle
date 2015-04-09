Given(/^there are "(.*?)" production_runs$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  create_list(:production_run, 2, bakery: bakery)
end

Given(/^there is a production run for another bakery$/) do
  create(:production_run)
end

Then(/^I should see production runs for "(.*?)"$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  production_run = bakery.production_runs.first
  expect(page).to have_content("#{production_run.id}: #{production_run.date}")
end

Then(/^I should not see production run that do not belong to "(.*?)"/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  production_run = ProductionRun.where.not(bakery: bakery).first
  expect(page).to_not have_content("#{production_run.id}: #{production_run.date}")
end

Given(/^there is a run item for a "(.*?)" production run$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  create(:run_item, production_run: bakery.production_runs.last, product: bakery.products.first)
end

Given(/^I am on a "(.*?)" production run with run items page$/) do |bakery|
  bakery = Bakery.find_by(name: bakery)
  visit edit_production_run_path(bakery.production_runs.first)
end

When(/^I fill out run item form with:$/) do |table|
  all(:xpath, '//select').last.find(:xpath, "option[text()='#{table.hashes[0]['product']}']").click
  all('.new_run_item_overbake_quantity').last.set(table.hashes[0]['overbake_quantity'])
end

When(/^I change the overbake quantity on the existing run item$/) do
  fill_in 'production_run_run_items_attributes_0_overbake_quantity', with: 33
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
