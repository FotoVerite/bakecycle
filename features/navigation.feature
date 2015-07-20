Feature: Navigation

  Scenario: As a user, I should be able to visit ingredients index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Ingredients"
    Then "Add New Ingredient" should be present

  Scenario: As a user, I should be able to visit recipes index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Recipes"
    Then "Add New Recipe" should be present

  Scenario: As a user, I should be able to visit products index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Products"
    Then "Add New Product" should be present

  Scenario: As a user, I should be able to visit routes index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Routes"
    Then "Add New Route" should be present

  Scenario: As a user, I should be able to visit clients index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Clients"
    Then "Add New Client" should be present

  Scenario: As a user, I should be able to visit Orders index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Orders"
    Then "Add New Order" should be present

  Scenario: As a user, I should be able to visit Shipments index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Invoices"
    Then "Add New Invoice" should be present

  Scenario: As a admin, I should be able to visit Bakeries index from the dashboard
    Given I am logged in as an admin
    When I go to the dashboard
    And I click on "Bakeries"
    Then "Add New Bakery" should be present

  Scenario: As a user, I should be able to visit My Bakery from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "My Bakery"
    Then "Editing Bakery" should be present

  Scenario: As an admin, I should not be able to view My Bakery on the dashboard
    Given I am logged in as an admin
    When I go to the dashboard
    Then "My Bakery" should not be present

  Scenario: As a user, I should be able to visit Print Daily Totals from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Print Daily Totals"
    Then "Daily Totals" should be present

  Scenario: As a user, I should be able to visit Print Delivery List from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on "Print Delivery Lists"
    Then "Delivery Lists" should be present
