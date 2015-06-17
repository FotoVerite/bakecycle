Feature: Ingredients

  @javascript
  Scenario: As a user with full access to ingredients
    Given I am logged in as an user with product "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery ingredients named "celery" and "almond"
    And I am on the "ingredients" page
    Then I should see a list of ingredients including "celery" and "almond"
    When I click on "celery"
    Then I should see "Ingredient" information about "celery"

    When I am on the "ingredients" page
    And I click on "Add New Ingredient"
    And I fill out Ingredient form with:
      | name  | description        |
      | apple | I am sometimes red |
    And I click on "Create"
    Then "You have created apple" should be present

    When I am on the edit page for "celery" ingredient
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the ingredient "celery" was deleted
    And The ingredient "celery" should not be present

    And I am on the edit page for "almond" ingredient
    And I change the ingredient name to "mushroom"
    And I click on "Update"
    Then I should see that the ingredient name is "mushroom"
    When I click on "Back"
    Then I should be on the "Ingredients" index page
    And "mushroom" should be present
    And "almond" should not be present

  Scenario: As a user with read access to ingredients
    Given I am logged in as an user with product "read" access with a bakery called "biencuit"
    And There are "biencuit" bakery ingredients named "celery" and "almond"
    And I am on the "ingredients" page
    Then I should see a list of ingredients including "celery" and "almond"
    When I click on "celery"
    Then "You are not authorized to access this page." should be present

  Scenario: As a user with none access to ingredients
    Given I am logged in as an user with product "none" access with a bakery called "biencuit"
    And There are "biencuit" bakery ingredients named "celery" and "almond"
    When I attempt to visit the "ingredients" page
    Then "You are not authorized to access this page." should be present
