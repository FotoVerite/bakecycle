Feature: Routes

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"

  Scenario: As a user, I should be able to view routes index
    Given I am on the "routes" page
    Then I should see a list of routes including "Canal" and "Chinatown"
    When I click on "Canal"
    Then I should see "Route" information about "Canal"

  Scenario: As a user, I should be able to add a route
    Given I am on the "routes" page
    And I click on "Add New Route"
    And I fill out Route form with:
      | name   | notes                 | active  | time   |
      | Corona | First queens location | false   | 6:30PM |
    And I click on "Create"
    Then "You have created Corona" should be present

  @javascript
  Scenario: As a user, I should be able to delete a route
    When I am on the edit page for "Canal" route
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the route "Canal" was deleted
    And The route "Canal" should not be present


  Scenario: As a user, I should be able to edit a route
    When I am on the edit page for "Canal" route
    And I change the route name to "Flatbush"
    And I click on "Update"
    Then I should see that the route name is "Flatbush"
    When I click on "Back"
    Then I should be on the "Routes" index page
    And "Flatbush" should be present
    And "Canal" should not be present
