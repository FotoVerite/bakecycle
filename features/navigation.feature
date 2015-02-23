Feature: Navigation

  Scenario: As a user, I should be able to view ingredients index from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Ingredients"
    Then "Add New Ingredient" should be present

  Scenario: As a user, I should be able to view recipes index from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Recipes"
    Then "Add New Recipe" should be present

  Scenario: As a user, I should be able to view products index from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Products"
    Then "Add New Product" should be present

  Scenario: As a user, I should be able to view routes index from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Routes"
    Then "Add New Route" should be present

  Scenario: As a user, I should be able to view clients index from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Clients"
    Then "Add New Client" should be present

  Scenario: As a user, I should be able to view Orders index from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Orders"
    Then "Add New Order" should be present

  Scenario: As a user, I should be able to view Shipments index from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Shipments"
    Then "Add New Shipment" should be present

  Scenario: As a admin, I should be able to view Bakeries index from the dashboard
    Given I am logged in as an admin
    When I go to the home page
    And I click on "Bakeries"
    Then "Add New Bakery" should be present
    When I go to the "ingredients" page
    Then "Ingredients" should be present

  Scenario: As a admin_bakery, I should be able to see both admin and bakery navigation
    Given I am logged in as an admin
    When I go to the home page
    And I click on "Bakeries"
    Then "Add New Bakery" should be present
    When I go to the "ingredients" page
    Then "Add New Ingredient" should be present

  Scenario: As a user, I should be able to view My Bakery from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "My Bakery"
    Then "Editing Bakery" should be present

  Scenario: As an admin, I should not see My Bakery on the dashboard
    Given I am logged in as an admin
    When I go to the home page
    Then "My Bakery" should not be present

  Scenario: As a user, I should be able to view Daily Totals from the dashboard
    Given I am logged in as a user
    When I go to the home page
    And I click on "Daily Totals"
    Then "Generate Daily Total" should be present
