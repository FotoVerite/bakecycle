Feature: Admin

  Scenario: As a admin, I can view what bakery a user belongs to
    Given I am logged in as an admin
    And there is a user named "Andrew"
    When I go to the "users" page
    Then I should see a bakeries column
