Feature: Navigation

  Scenario: As a user, I should be able to visit ingredients index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Ingredients" link
    Then "Add New Ingredient" should be present

  Scenario: As a user, I should be able to visit recipes index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Recipes" link
    Then "Add New Recipe" should be present

  Scenario: As a user, I should be able to visit products index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Products" link
    Then "Add New Product" should be present

  Scenario: As a user, I should be able to visit routes index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Routes" link
    Then "Add New Route" should be present

  Scenario: As a user, I should be able to visit clients index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Clients" link
    Then "Add New Client" should be present

  Scenario: As a user, I should be able to visit Orders index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Orders" link
    Then "Add New Order" should be present

  Scenario: As a user, I should be able to visit Shipments index from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Invoices" link
    Then "Add New Invoice" should be present

  Scenario: As a admin, I should be able to visit Bakeries index from the dashboard
    Given I am logged in as an admin
    When I go to the dashboard
    And I click on the "Bakeries" link
    Then "Add New Bakery" should be present

  Scenario: As a user, I should be able to visit My Bakery from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "My Bakery" link
    Then "Editing Bakery" should be present

  Scenario: As an admin, I should not be able to view My Bakery on the dashboard
    Given I am logged in as an admin
    When I go to the dashboard
    Then "My Bakery" should not be present

  Scenario: As a user, I should be able to visit Print Daily Totals from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Print Daily Totals" link
    Then "Daily Totals" should be present

  Scenario: As a user, I should be able to visit Print Delivery List from the dashboard
    Given I am logged in as a user
    When I go to the dashboard
    And I click on the "Print Delivery Lists" link
    Then "Delivery Lists" should be present
