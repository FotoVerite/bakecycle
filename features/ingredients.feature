Feature: Ingredients

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery ingredients named "celery" and "almond"

  Scenario: As a user, I should be able to view ingredients index
    Given I am on the "ingredients" page
    Then I should see a list of ingredients including "celery" and "almond"
    When I click on "celery"
    Then I should see "Ingredient" information about "celery"

  Scenario: As a user, I should be able to add an ingredient
		Given I am on the "ingredients" page
		And I click on "Add New Ingredient"
		And I fill out Ingredient form with:
		  | name  | price | measure | unit | ingredient_type | description        |
		  | apple | 1.10  | 2.225   | lb   | flour           | I am sometimes red |
    And I click on "Create"
    Then "You have created apple" should be present

  @javascript
  Scenario: As a user, I should be able to delete an ingredient
    Given I am on the edit page for "celery" ingredient
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the ingredient "celery" was deleted
    And The ingredient "celery" should not be present

  Scenario: As a user, I should be able to edit an ingredient
    Given I am on the edit page for "celery" ingredient
    And I change the ingredient name to "mushroom"
    And I click on "Update"
    Then I should see that the ingredient name is "mushroom"
    When I click on "Back"
    Then I should be on the "Ingredients" index page
    And "mushroom" should be present
    And "celery" should not be present
