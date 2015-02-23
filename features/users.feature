Feature: Users

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are users named "andy","francis" and they belong to "biencuit" bakery

  Scenario: As a user, I can visit products page
    When I go to the "products" page
    Then "You need to sign in or sign up before continuing" should not be present
    And "Products" page header should be present

  Scenario: As a user, I can visit recipes page
    When I go to the "recipes" page
    Then "You need to sign in or sign up before continuing" should not be present
    And "Recipes" page header should be present

  Scenario: As a user, I can visit ingredients pages
    When I go to the "ingredients" page
    Then "You need to sign in or sign up before continuing" should not be present
    And "Ingredients" page header should be present

  Scenario: As a user, if I can logout
    When I go to the home page
    And I logout
    Then "Signed out successfully" should be present

  Scenario: As a user, I can view all users
    When I go to the "users" page
    Then I should see a list of users including "andy" and "francis"
    When I click on "andy"
    Then I should be redirected to an user page

  Scenario: As a user, I can create a user
    When I go to the "users" page
    And I click on "Add New User"
    And I fill out User form with:
      | email                |  password  |  password_confirmation  |  name    |
      | new_user@example.com |  foobarbaz |  foobarbaz              | John Doe |
    And I click on "Create"
    Then "You have created a new user for John Doe with new_user@example.com" should be present

  Scenario: As an user, I can edit a user
    When I am on the edit page for "andy" user
    And I change the user name to "andrew"
    And I click on "Update"
    Then I should see that the user name is "andrew"
    When I click on "Back"
    Then I should be on the "User" index page
    And "andrew" should be present
    And "andy" should not be present

  @javascript
  Scenario: As a user, I can delete a user
    When I am on the edit page for "andy" user
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the user "andy" was deleted
    And The user "andy" should not be present
