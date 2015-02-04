Feature: Bakery

  Background:
    Given I am logged in as an admin
    And There are bakeries named "Biencuit","Grumpy" and "Wonder"]

  Scenario: As an Admin, I can view all bakeries
    Given I am on the "bakeries" page
    Then I should see a list of routes including "Biencuit", "Grumpy" and "Wonder"
    When I click on "Wonder"
    Then I should see information about the "Wonder" bakery

  Scenario: As an Admin, I can create a Bakery
    When I go to the "bakeries" page
    And I click on "Add New Bakery"
    And I fill out Bakery form with:
      | name        |
      | Au Bon Pain |
    And I click on "Create"
    Then "You have created Au Bon Pain" should be present

  Scenario: As an Admin, I can edit a Bakery
    Given I am on the edit page for "Grumpy" bakery
    When I change the bakery name to "Cheeky's"
    And I click on "Update"
    Then I should see that the bakery name is "Cheeky's"
    When I click on "Back"
    Then I should be on the "Bakeries" index page
    And "Cheeky's" should be present
    And "Grumpy" should not be present

  @javascript
  Scenario: As an Admin, I can delete a Bakery
    Given I am on the edit page for "Wonder" bakery
    When I click on "Delete"
    And I confirm popup
    Then I should see confirmation the bakery was deleted
    And the bakery "Wonder" should not be present

  Scenario: As an User, I cannot see bakeries
    Given I am logged in as a user
    And I go to the "bakeries" page
    Then "You are not authorized to access this page." should be present
