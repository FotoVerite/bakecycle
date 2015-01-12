Given(/^There are orders with clients named "(.*?)","(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  client1 = create(:client, name: name1)
  client2 = create(:client, name: name2)
  client3 = create(:client, name: name3)
  create(:order, client: client1)
  create(:order, client: client2)
  create(:order, client: client3)
end

Then(/^I should see a list of orders including clients named "(.*?)","(.*?)" and "(.*?)"$/) do |name1, name2, name3|
  expect(page).to have_content(name1)
  expect(page).to have_content(name2)
  expect(page).to have_content(name3)
end

Then(/^I should be redirected to an order page$/) do
  expect(page).to have_css('form')
  expect(page).to have_content('Order')
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

Then(/^I should be redirected to the Orders page$/) do
  expect(page).to have_content("Orders")
end

When(/^I change the order name to "(.*?)"$/) do |name|
  select name, from: "order_client_id"
end

Then(/^I should see that the order name is "(.*?)"$/) do |name|
  expect(page).to have_content(name)
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
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../../..")
  form.find('a', text: "X").click
end

When(/^I edit the order item "(.*?)" "(.*?)" quantity with "(.*?)"$/) do |name, day, quantity|
  form = find(:xpath, "//select/option[@selected='selected' and text()='#{name}']/../../../..")
  form.find_field(day).set(quantity)
end

Then(/^the order item "(.*?)" should be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to_not raise_error
end

Then(/^the order item "(.*?)" should not be present$/) do |name|
  expect { find(:xpath, "//select/option[@selected='selected' and text()='#{name}']") }.to raise_error
end
