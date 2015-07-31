Given(/^There is bakery plans available$/) do
  create(:plan, name: "beta_small", display_name: "Small Bakery")
  create(:plan, name: "beta_medium", display_name: "Medium Bakery")
  create(:plan, name: "beta_large", display_name: "Large Bakery")
end

Given(/^There is a bakery named "(.*?)"$/) do |name|
  create(:bakery, name: name)
end

Given(/^A user with the email "(.*?)"$/) do |email|
  create(:user, email: email)
end

When(/^I go to the new registrations page$/) do
  visit new_registration_path
end

When(/^I submit the registration form with valid data$/) do
  plan = Plan.find_by(name: "beta_small")
  find("label[for=registration_plan_id_#{plan.id}]").click
  fill_in "registration_first_name", with: "john"
  fill_in "registration_last_name", with: "dough"
  fill_in "registration_bakery_name", with: "FitBake"
  fill_in "registration_email", with: "j@dough.com"
  fill_in "registration_password", with: "foobarbaz"
  # fill_in 'registration_card_number', with: '4242424242424242'
  # fill_in 'registration_card_zipcode', with: '12123'
  # fill_in 'registration_card_code', with: '121'
  # select '2', from: 'registration_card_month'
  # select '2016', from: 'registration_card_year'
  click_on "Join BakeCycle"
end

Then(/^I should be on the user's dashboard page$/) do
  find("h1").should have_content("Dashboard")
end

When(/^I choose small plan$/) do
  within(".small-plan") do
    find(".cta-btn").click
  end
end

Then(/^I should be on the registrations page$/) do
  find("h1").should have_content("SIGN UP FOR BAKECYCLE")
end

When(/^I attempt to visit the registrations page again$/) do
  step "I go to the new registrations page"
end

Then(/^I should see "(.*?)" plan selected$/) do |plan_name|
  plan_id = Plan.find_by(name: plan_name).id
  expect(find(:css, "#registration_plan_id_#{plan_id}", visible: false)).to be_checked
end

When(/^I fill out the rest of the registrations form with:$/) do |table|
  fill_in "registration_first_name", with: table.hashes[0]["first"]
  fill_in "registration_last_name", with: table.hashes[0]["last"]
  fill_in "registration_bakery_name", with: table.hashes[0]["bakery_name"]
  fill_in "registration_email", with: table.hashes[0]["email"]
  fill_in "registration_password", with: table.hashes[0]["password"]
end

Then(/^I should be on the plans page$/) do
  expect(page).to have_css("h2", text: "Pricing")
end
