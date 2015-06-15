Feature: Admin

  Scenario: As a admin, I can create a user with bakery
    Given I am logged in as an admin
    And there is a bakery named "homies wonderland"
    When I go to the "users" page
    And I click on "Add New User"
    And I fill out User with bakery form with:
      | email                |  password  |  password_confirmation  |  name    | bakery            |
      | hommiexx@example.com |  foobarbaz |  foobarbaz              | John Poe | homies wonderland |
    And I click on "Create"
    Then "You have created a new user for John Poe with hommiexx@example.com" should be present

  Scenario: As a admin, I can view what bakery a user belongs to
    Given I am logged in as an admin
    And there is a user named "Andrew"
    When I go to the "users" page
    Then I should see a bakeries column
