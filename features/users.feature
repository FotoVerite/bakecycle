Feature: Users

  Background:
    Given I am logged in as a user

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
    And I click on "Logout"
    Then "Signed out successfully" should be present
