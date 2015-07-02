Then(/^I should see a bakeries column$/) do
  find('.responsive-table').should have_content('Bakery')
end
