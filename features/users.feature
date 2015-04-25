Feature: Users
  Background:
    Given I am logged in as a user

  Scenario: As a user, I can visit major sections
    When I go to the "products" page
    And "Products" page header should be present

    When I go to the "recipes" page
    And "Recipes" page header should be present

    When I go to the "ingredients" page
    And "Ingredients" page header should be present

    When I logout
    Then "Signed out successfully" should be present

  Scenario: As a user, I can view all users
    And there is a user named "Andrew"
    When I go to the "users" page
    Then I should see a list of users including "Andrew"
    When I click on "Andrew"
    Then I should information about the user "Andrew"

  Scenario: As a user, I can create manage other users
    When I go to the "users" page
    And I click on "Add New User"
    And I fill out User form with:
      | email                |  password  |  password_confirmation  |  name    |
      | new_user@example.com |  foobarbaz |  foobarbaz              | John Doe |
    And I click on "Create"
    Then "You have created a new user for John Doe with new_user@example.com" should be present

    When I edit the user "John Doe"
    And I change the user name to "Andrew"
    And I click on "Update"
    Then I should see that the user name is "Andrew"

    When I go to the "users" page
    Then "Andrew" should be present
    And "John Doe" should not be present

  Scenario: As a user, I can delete a user
    Given there is a user named "Andrew"
    When I edit the user "Andrew"
    And I click on "Delete"
    Then I should see confirmation that the user "Andrew" was deleted
    And The user "Andrew" should not be present
