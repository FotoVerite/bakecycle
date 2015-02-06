Feature: Clients

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And there is a bakery called "grumpy"
    And There are "biencuit" bakery clients named "andysdecaf" and "mandos"
    And There are "grumpy" bakery clients named "james" and "bob"

  Scenario: As a user, I should be able to view clients
    Given I am on the "clients" page
    Then I should see a list of clients including "andysdecaf" and "mandos"
    And I should not see clients "james" and "bob"
    When I click on "andysdecaf"
    Then I should see "Client" information about "andysdecaf"

  Scenario: As a user, I should be able to add a client
    Given I am on the "clients" page
    When I click on "Add New Client"
    And I fill out Client form with valid data
    And I click on "Create"
    Then "You have created Test" should be present

  @javascript
  Scenario: As a user, I should be able to delete a client
    When I am on the edit page for "andysdecaf" client
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the client "andysdecaf" was deleted
    And The client "andysdecaf" should not be present

  Scenario: As a user, I should be able to edit a client
    When I am on the edit page for "andysdecaf" client
    And I change the client name to "amymushroom"
    And I click on "Update"
    Then "amymushroom" should be present
    When I click on "Back"
    And I go to the "clients" page
    Then "amymushroom" should be present
    And the client "andysdecaf" should not be present

  Scenario: As a user, I should be able to view a clients recent purchases in the client's index page and be able to click to see more shipments for that client
    Given That there's shipments for "mandos" and "andysdecaf"
    When I am on the view page for "mandos"
    Then I should see recent shipments information
    When I click on "View More Shipments"
    Then I should be on the shipment's index page with "mandos" shipments and none from "andysdecaf"
