Feature: Clients

  Background:
    Given I am logged in as a user
    And There are clients named "amyavocado","andysdecaf" and "mandos"

  Scenario: As a user, I should be able to view clients
    When I go to the "clients" page
    Then I should see a list of clients including "amyavocado", "andysdecaf" and "mandos"
    When I click on "amyavocado"
    Then I should be redirected to a client page with the name "amyavocado"

  Scenario: As a user, I should be able to add a client
    When I go to the "clients" page
    And I click on "Add New Client"
    And I fill out Client form with valid data
    And I click on "Create"
    Then "You have created Test" should be present

  @javascript
  Scenario: As a user, I should be able to delete a client
    When I am on the edit page for "amyavocado" client
    And I click on "Delete"
    And I confirm popup
    Then I should be redirected to the Clients page
    And "amyavocado" should not be present

  Scenario: As a user, I should be able to edit a client
    When I am on the edit page for "amyavocado" client
    And I change the client name to "amymushroom"
    And I click on "Update"
    Then "amymushroom" should be present
    When I click on "Back"
    And I go to the "clients" page
    Then "amymushroom" should be present
    And "amyavocado" should not be present
