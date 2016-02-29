Given(/^There are "(.*?)" bakery orders with clients named "(.*?)" and "(.*?)"$/) do |bakery, name1, name2|
  bakery = Bakery.find_by(name: bakery)
  client1 = Client.find_by(name: name1)
  client2 = Client.find_by(name: name2)
  route = create(:route, bakery: bakery)
  create(:order, client: client1, bakery: bakery, route: route)
  create(:order, client: client2, bakery: bakery, route: route)
end

Then(/^I should see a list of orders including clients named "(.*?)" and "(.*?)"$/) do |name1, name2|
  within ".responsive-table" do
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
  fill_in "Start Date", with: ""
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
    ".fields:last .sunday" => form["sunday"],
    ".fields:last select" => form["product"]
  )
end

When(/^I fill out the temporary order item form with:$/) do |table|
  form = table.hashes[0]
  jquery_fill(
    ".fields:last .select" => form["product"],
    ".fields:last .friday_input" => form["friday"]
  )
end

When(/^I delete "(.*?)" order item$/) do |name|
  row = find(:xpath, "//option[@selected and text()='#{name}']/../../../..")
  row.find("a", text: "X").click
end

When(/^I delete the first order item$/) do
  all("a", text: "X").first.click
end

When(/^I edit the order item "(.*?)" "(.*?)" quantity with "(.*?)"$/) do |name, day, quantity|
  form = find(:xpath, "//select/option[@selected and text()='#{name}']/../../../..")
  form.find_field(day).set(quantity)
end

Then(/^the order item "(.*?)" should be present$/) do |name|
  expect(page).to have_xpath("//select/option[@selected and text()='#{name}']")
end

Then(/^the order item "(.*?)" should not be present$/) do |name|
  expect(page).to have_no_selector(:xpath, "//select/option[@selected and text()='#{name}']")
end

Then(/^The order "(.*?)" should not be present$/) do |order|
  within ".responsive-table" do
    expect(page).to_not have_content(order)
  end
end

Then(/^I should see confirmation that the "(.*?)" order "(.*?)" was deleted$/) do |order_type, order|
  within ".alert-box" do
    expect(page).to have_content("You have deleted the #{order_type} order for #{order}")
  end
end

Then(/^I should see order information about "(.*?)"$/) do |name|
  expect(page).to have_content(/Editing Order: \d+ \- #{name}/)
end

When(/^I click the order "(.*?)"$/) do |order_client|
  client = Client.find_by(name: order_client)
  order = Order.find_by(client: client)
  within(".responsive-table") do
    find("a.order-#{order.id}").click
  end
end
