Feature: Routes

  Background:
    Given I am logged in as a user
    And There are routes named "Canal","Chinatown" and "LES"

  Scenario: As a user, I should be able to view routes index
    When I go to the "routes" page
    Then I should see a list of routes including "Canal", "Chinatown" and "LES"
    When I click on "Canal"
    Then I should be redirected to a route page

  Scenario: As a user, I should be able to add a route
    When I go to the "routes" page
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
    Then I should be redirected to the Routes page
    And "Canal" should not be present

  Scenario: As a user, I should be able to edit a route
    When I am on the edit page for "Canal" route
    And I change the route name to "Flatbush"
    And I click on "Update"
    Then I should see that the route name is "Flatbush"
    When I click on "Back"
    Then I should be on the "Routes" index page
    And "Flatbush" should be present
    And "Canal" should not be present
