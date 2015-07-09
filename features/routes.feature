Feature: Routes

  @javascript
  Scenario: As a user with full access to routes
    Given I am logged in as an user with route "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"

    When I am on the "routes" page
    Then I should see a list of routes including "Canal" and "Chinatown"
    When I click on "Canal"
    Then I should see "Route" information about "Canal"

    When I am on the "routes" page
    And I click on "Add New Route"
    And I fill out Route form with:
      | name   | notes                 | active  | time   |
      | Corona | First queens location | false   | 6:30PM |
    And I click on "Create"
    Then "You have created Corona" should be present

    When I am on the edit page for "Canal" route
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the route "Canal" was deleted
    And The route "Canal" should not be present

    When I am on the edit page for "Corona" route
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the route "Corona" was deleted
    And The route "Corona" should not be present

    When I am on the edit page for "Chinatown" route
    And I click on "Delete"
    And I confirm popup
    Then "Cannot delete last remaining route" should be present

    When I am on the edit page for "Chinatown" route
    And I change the route name to "Flatbush"
    And I click on "Update"
    Then I should see that the route name is "Flatbush"
    When I click on "Back"
    Then I should be on the "Routes" index page
    And "Flatbush" should be present
    And "Chinatown" should not be present

  Scenario: As a user with read access to routes
    Given I am logged in as an user with route "read" access with a bakery called "biencuit"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"

    When I am on the "routes" page
    Then I should see a list of routes including "Canal" and "Chinatown"
    When I click on "Canal"
    Then "You are not authorized to access this page." should be present

  Scenario: As a user with none access to routes
    Given I am logged in as an user with route "none" access with a bakery called "biencuit"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    When I attempt to visit the "routes" page
    Then "You are not authorized to access this page." should be present
