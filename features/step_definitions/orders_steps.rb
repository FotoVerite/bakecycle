Given(/^There are "(.*?)" bakery orders with clients named "(.*?)" and "(.*?)"$/) do |bakery, name1, name2|
  bakery = Bakery.find_by(name: bakery)
  client1 = Client.find_by(name: name1)
  client2 = Client.find_by(name: name2)
  route = create(:route, bakery: bakery)
  order1 = create(:order, client: client1, bakery: bakery, route: route)
  order2 = create(:order, client: client2, bakery: bakery, route: route)
  create(:shipment, client: client1, bakery: bakery, date: Time.zone.now, order: order1)
  create(:shipment, client: client1, bakery: bakery, date: Time.zone.now, order: order2)
end

# rubocop:disable LineLength
Given(/^There are "(.*?)" bakery orders without shipments with clients named "(.*?)" and "(.*?)"$/) do |bakery, name1, name2|
  bakery = Bakery.find_by(name: bakery)
  client1 = Client.find_by(name: name1)
  client2 = Client.find_by(name: name2)
  route = create(:route, bakery: bakery)
  create(:order, :active, client: client1, bakery: bakery, route: route)
  create(:order, :active, client: client2, bakery: bakery, route: route)
end
# rubocop:enable LineLength

Then(/^I should see a list of missing shipments including clients named "(.*?)" and "(.*?)"$/) do |name1, name2|
  within ".orders-missing-shipment-table" do
    expect(page).to have_content(name1)
    expect(page).to have_content(name2)
  end
end

And(/^I should see the callout "(.*?)"$/) do |text|
  within "div.callout" do
    page.should have_content(text)
  end
end

Then(/^I should see a list of orders including clients named "(.*?)" and "(.*?)"$/) do |name1, name2|
  within ".order-index-table" do
    expect(page).to have_content(name1)
    expect(page).to have_content(name2)
  end
end

When(/^I fill out Order form with:$/) do |table|
  choose table.hashes[0]["order_type"].titleize
  select table.hashes[0]["route"], from: "Route"
  select table.hashes[0]["client"], from: "Client"
  order = table.hashes[0]
  fill_in "Start Date", with: ""
  fill_in "Start Date", with: order["start_date"]
  fill_in "End Date", with: ""
  fill_in "End Date", with: order["end_date"]
  jquery_fill(
    ".note" => order["note"]
  )
end

When(/^I fill out temporary order form with:$/) do |table|
  choose table.hashes[0]["order_type"].titleize
  select table.hashes[0]["route"], from: "Route"
  select table.hashes[0]["client"], from: "Client"
  order = table.hashes[0]
  fill_in "Start Date", with: ""
  fill_in "Start Date", with: order["start_date"]
  jquery_fill(
    ".note" => order["note"]
  )
end

When(/^I edit the order form with:$/) do |table|
  choose table.hashes[0]["order_type"].titleize
  order = table.hashes[0]
  fill_in "Start Date", with: order["start_date"]
end

When(/^I am on the edit page for "(.*?)" order$/) do |name|
  client = Client.find_by(name: name)
  order = Order.find_by(client: client)
  visit edit_order_path(order)
end

When(/^I fill out the order item form with:$/) do |table|
  form = table.hashes[0]
  jquery_fill(
    ".fields:last .monday" => form["monday"],
    ".fields:last .tuesday" => form["tuesday"],
    ".fields:last .wednesday" => form["wednesday"],
    ".fields:last .thursday" => form["thursday"],
    ".fields:last .friday" => form["friday"],
    ".fields:last .saturday" => form["saturday"],
    ".fields:last .sunday" => form["sunday"]
  )
  product_selector = all(".select .productId input").last
  product_selector.set(form["product"])
  send_return(product_selector)
end

When(/^I fill out the temporary order item form with:$/) do |table|
  form = table.hashes[0]
  jquery_fill(
    ".fields:last .friday_input" => form["friday"]
  )
  product_selector = all(".select .productId input").last
  product_selector.set(form["product"])
  product_selector.native.send_keys(:return)
end

When(/^I delete the "(.*?)" order item$/) do |product_name|
  form = find(:xpath, "//span[text()='#{product_name}']/../../../../../..")
  form.find("a", text: "X").click
end

When(/^I edit the order item "(.*?)" "(.*?)" quantity with "(.*?)"$/) do |name, day, quantity|
  form = find(:xpath, "//span[text()='#{name}']/../../../../../..")
  form.find_field(day).set(quantity)
end

Then(/^the order item "(.*?)" should be present$/) do |name|
  within ".edit_order" do
    expect(page).to have_content name
  end
end

Then(/^the order item "(.*?)" should not be present$/) do |name|
  within ".edit_order" do
    expect(page).to_not have_content name
  end
end

Then(/^The order "(.*?)" should not be present$/) do |order|
  within ".order-index-table" do
    expect(page).to_not have_content(order)
  end
end

Then(/^I should see confirmation that the "(.*?)" order "(.*?)" was deleted$/) do |order_type, order|
  within ".alert-box" do
    expect(page).to have_content("You have deleted the #{order_type} order for #{order}")
  end
end

Then(/^I should see order information about "(.*?)"$/) do |name|
  expect(page).to have_content(/Editing Order #\d+ \- #{name}/)
end

When(/^I click the order "(.*?)"$/) do |order_client|
  client = Client.find_by(name: order_client)
  order = Order.find_by(client: client)
  within(".order-index-table") do
    find("a.order-#{order.id}").click
  end
end
