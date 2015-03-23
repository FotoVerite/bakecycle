Feature: Visitors

  Scenario: As a visitor, I should be able to view the home page
    Given I am a visitor
    When I go to the home page
    Then "Wholesale Bakery Management" should be present
    And "Login" should be present

  Scenario: As a visitor, I should not be able to view Ingredients
    Given I am a visitor
    When I go to the "ingredients" page
    Then "You need to sign in or sign up before continuing" should be present

  Scenario: As a visitor, I should not be able to view Recipes
    Given I am a visitor
    When I go to the "recipes" page
    Then "You need to sign in or sign up before continuing" should be present

  Scenario: As a visitor, I should not be able to view Products
    Given I am a visitor
    When I go to the "products" page
    Then "You need to sign in or sign up before continuing" should be present
