Feature: Ingredients Index
  @javascript
	Scenario: As a visitor, I should be able to view ingredients index
		Given I am a visitor
		And There are ingredients named "celery","carrot" and "almond"
		When I go to the ingredients page
		Then I should see a list of ingredients including "celery", "carrot" and "almond"
		When I click on "celery"
		Then I should be redirected to an ingredient page

  @javascript
	Scenario: As a visitor, I should be able to add an ingredient
		Given I am a visitor
		When I go to the ingredients page
		And I click on "Add New Ingredient"
		And I fill out Ingredient form with:
		  | name  | price | measure | unit | ingredient_type | description        |
		  | apple | 1.10  | 2.225   | lb   | flour           | I am sometimes red |
    Then "You have created apple" should be present

  @javascript
	Scenario: As a visitor, I should be able to delete an ingredient
	  Given I am a visitor
	  And There are ingredients named "celery","carrot" and "almond"
	  And I am on the edit page for "celery" ingredient
	  When I click on "Delete"
	  And I confirm popup
	  Then I should be redirected to the Ingredients page
	  And "celery" should not be present

  Scenario: As a visitor, I should be able to edit an ingredient
    Given I am a visitor
    And There are ingredients named "celery","carrot" and "almond"
    And I am on the edit page for "celery" ingredient
    When I change the ingredient name to "mushroom"
    And I click on "Update"
    Then I should see that the ingredient name is "mushroom"
    When I click on "Back"
    Then I should be on the "Ingredients" index page
    And "mushroom" should be present
    And "celery" should not be present
