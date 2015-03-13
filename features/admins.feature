Feature: Admin

  Background:
    Given I am logged in as an admin
    And There are bakeries named "biencuit","grumpy" and "ovenly"

  Scenario: As a admin, I can create a user with bakery
    When I go to the "users" page
    And I click on "Add New User"
    And I fill out User with bakery form with:
      | email                |  password  |  password_confirmation  |  name    | bakery   |
      | new_user@example.com |  foobarbaz |  foobarbaz              | John Doe | biencuit |
    And I click on "Create"
    Then "You have created a new user for John Doe with new_user@example.com" should be present
