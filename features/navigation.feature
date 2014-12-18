Feature: Navigation

  Background:
    Given I am logged in as a user

  Scenario: As a user, I should be able to view ingredients index from the dashboard
    When I go to the home page
    And I click on "Ingredients"
    Then "Add New Ingredient" should be present

  Scenario: As a user, I should be able to view recipes index from the dashboard
    When I go to the home page
    And I click on "Recipes"
    Then "Add New Recipe" should be present

  Scenario: As a user, I should be able to view products index from the dashboard
    When I go to the home page
    And I click on "Products"
    Then "Add New Product" should be present

  Scenario: As a user, I should be able to view routes index from the dashboard
    When I go to the home page
    And I click on "Routes"
    Then "Add New Route" should be present

  Scenario: As a user, I should be able to view clients index from the dashboard
    When I go to the home page
    And I click on "Clients"
    Then "Add New Client" should be present

  Scenario: As a user, I should be able to view Orders index from the dashboard
    When I go to the home page
    And I click on "Orders"
    Then "Add New Order" should be present
