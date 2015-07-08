Feature: Clients

  @javascript
  Scenario: As a user with full access to clients
    Given I am logged in as an user with client "manage" access with a bakery called "biencuit"
    And there is a bakery called "grumpy"
    And There are "biencuit" bakery clients named "mandos" and "andysdecaf"
    And There are "grumpy" bakery clients named "james" and "bob"
    And That there's shipments for "mandos" and "andysdecaf"
    And That there's orders for "mandos" and "andysdecaf"

    When I am on the "clients" page
    Then I should see a list of clients including "andysdecaf" and "mandos"
    And I should not see clients "james" and "bob"
    When I click on "andysdecaf"
    Then I should see "Client" information about "andysdecaf"

    When I am on the "clients" page
    When I click on "Add New Client"
    And I fill out the client "Wizards Coffee" with valid data
    And I click on "Create"
    Then "You have created Wizards Coffee" should be present

    When I am on the edit page for the client "Wizards Coffee"
    And I change the client name to "Joshys Coffee"
    And I click on "Update"
    Then "Joshys Coffee" should be present
    When I click on "Back"
    And I go to the "clients" page
    Then "Joshys Coffee" should be present
    And the client "Wizards Coffee" should not be present

    When I am on the edit page for the client "Joshys Coffee"
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the client "Joshys Coffee" was deleted
    And The client "Joshys Coffee" should not be present

    When I am on the view page for "mandos"
    Then I should see recent shipments information
    When I click on "View More Shipments"
    Then I should be on the shipment's index page with "mandos" shipments and none from "andysdecaf"

    When I am on the view page for "mandos"
    Then I should see upcoming orders information
    When I click on "View More Orders"
    Then I should be on the orders index page with "mandos" shipments and none from "andysdecaf"

  Scenario: As a user with read access to clients
    Given I am logged in as an user with client "read" access with a bakery called "biencuit"
    And There are "biencuit" bakery clients named "mandos" and "andysdecaf"
    And That there's shipments for "mandos" and "andysdecaf"
    And That there's orders for "mandos" and "andysdecaf"

    When I am on the "clients" page
    Then I should see a list of clients including "andysdecaf" and "mandos"
    When I click on "andysdecaf"
    Then I should see "Client" information about "andysdecaf"

    When I attempt to visit "andysdecaf" edit page
    Then "You are not authorized to access this page." should be present

  Scenario: As a user with none access to clients
    Given I am logged in as an user with client "none" access with a bakery called "biencuit"
    And There are "biencuit" bakery clients named "mandos" and "andysdecaf"
    When I attempt to visit the "clients" page
    Then "You are not authorized to access this page." should be present
