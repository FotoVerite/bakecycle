Given(/^There are "(.*?)" bakery orders with clients named "(.*?)" and "(.*?)"$/) do |bakery, name1, name2|
  bakery = Bakery.find_by(name: bakery)
  client1 = Client.find_by(name: name1)
  client2 = Client.find_by(name: name2)
  route = create(:route, bakery: bakery)
  create(:order, client: client1, bakery: bakery, route: route)
  create(:order, client: client2, bakery: bakery, route: route)
end

Then(/^I should see a list of orders including clients named "(.*?)" and "(.*?)"$/) do |name1, name2|
  within '.responsive-table' do
    expect(page).to have_content(name1)
    expect(page).to have_content(name2)
  end
end

When(/^I fill out Order form with:$/) do |table|
  choose "order_order_type_#{table.hashes[0]['order_type']}"
  fill_in "order_start_date", with: table.hashes[0]["start_date"]
  fill_in "order_end_date", with: table.hashes[0]["end_date"]
  fill_in "order_note", with: table.hashes[0]["note"]
  select table.hashes[0]["route"], from: "order_route_id"
  select table.hashes[0]["client"], from: "order_client_id"
end

When(/^I fill out temporary order form with:$/) do |table|
  choose "order_order_type_#{table.hashes[0]['order_type']}"
  fill_in "order_start_date", with: table.hashes[0]["start_date"]
  fill_in "order_note", with: table.hashes[0]["note"]
  select table.hashes[0]["route"], from: "order_route_id"
  select table.hashes[0]["client"], from: "order_client_id"
end

When(/^I am on the edit page for "(.*?)" order$/) do |name|
  client = Client.find_by(name: name)
  order = Order.find_by(client: client)
  visit edit_order_path(order)
end

When(/^I fill out the order item form with:$/) do |table|
  all(:xpath, "//select").last.find(:xpath, "option[text()='#{table.hashes[0]['product']}']").click
  all('.monday_input').last.set(table.hashes[0]["monday"])
  all('.tuesday_input').last.set(table.hashes[0]["tuesday"])
  all('.wednesday_input').last.set(table.hashes[0]["wednesday"])
  all('.thursday_input').last.set(table.hashes[0]["thursday"])
  all('.friday_input').last.set(table.hashes[0]["friday"])
  all('.saturday_input').last.set(table.hashes[0]["saturday"])
  all('.sunday_input').last.set(table.hashes[0]["sunday"])
end

When(/^I fill out the temporary order item form with:$/) do |table|
  all(:xpath, "//select").last.find(:xpath, "option[text()='#{table.hashes[0]['product']}']").click
  all('.friday_input').last.set(table.hashes[0]["friday"])
end

When(/^I delete "(.*?)" order item$/) do |name|
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../../../..")
  form.find('a', text: "X").click
end

When(/^I edit the order item "(.*?)" "(.*?)" quantity with "(.*?)"$/) do |name, day, quantity|
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../../../..")
  form.find_field(day).set(quantity)
end

Then(/^the order item "(.*?)" should be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to_not raise_error
end

Then(/^the order item "(.*?)" should not be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to raise_error
end

Then(/^The order "(.*?)" should not be present$/) do |order|
  within '.responsive-table' do
    expect(page).to_not have_content(order)
  end
end

Then(/^I should see confirmation that the "(.*?)" order "(.*?)" was deleted$/) do |order_type, order|
  within '.alert-box' do
    expect(page).to have_content("You have deleted the #{order_type} order for #{order}")
  end
end

Then(/^I should see order information about "(.*?)"$/) do |name|
  expect(page).to have_content("Client Name: #{name}")
end

When(/^I click on the first order$/) do
  within '.responsive-table' do
    page.execute_script("$('.js-clickableRow:first').click();")
  end
end
