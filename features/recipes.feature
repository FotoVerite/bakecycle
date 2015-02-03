Feature: Recipes

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery recipes named "baguette" and "donut"
    And There are "biencuit" bakery ingredients named "celery" and "almond"

  Scenario: As a user, I should be able to view recipes index
    Given I am on the "recipes" page
    Then I should see a list of recipes including "baguette" and "donut"
    When I click on "baguette"
    Then I should see "Recipe" information about "baguette"

  @javascript
  Scenario: As a user, I should be able to add an recipe
    Given I am on the "recipes" page
    And I click on "Add New Recipe"
    And I fill out recipe form with:
      | name  | mix_size | mix_size_unit| lead_days | recipe_type | note                |
      | apple |  1.10    | kg           | 2         | dough       | I am made with love |
    And I click on "Create"
    Then "You have created apple" should be present

  @javascript
  Scenario: As a user, I should be able to delete an recipe
    When I am on the edit page for "baguette" recipe
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation the recipe "baguette" was deleted
    And the recipe "baguette" should not be present

  @javascript
  Scenario: As a user, I should be able to edit an recipe
    When I am on the edit page for "baguette" recipe
    And I change the recipe name to "danish"
    And I click on "Update"
    Then I should see that the recipe name is "danish"
    When I click on "Back"
    Then I should be on the "Recipes" index page
    And the recipe "danish" should be present
    And the recipe "baguette" should not be present

  @javascript
  Scenario: As a user, I should get an error if I try to add an empty recipe item to a recipe
    When I am on the edit page for "baguette" recipe
    When I click on "Add New Ingredient"
    And I click on "Update"
    Then "can't be blank" should be present
    And "Baker's % must be greater than 0.001" should be present

  @javascript
  Scenario: As a user, I should be able to add recipe items to an existing recipe
    When I am on the edit page for "baguette" recipe
    When I click on "Add New Ingredient"
    And I fill out recipe item with:
       | inclusionable_id_type | percentage |
       | baguette              | 22.5       |
    And I click on "Update"
    Then "You have updated baguette" should be present

  @javascript
  Scenario: As a user, I should be able to add a recipe with multiple items
    When I go to the "recipes" page
    And I click on "Add New Recipe"
    And I fill out recipe form with:
      | name  | mix_size | mix_size_unit| lead_days | recipe_type | note                |
      | apple | 1.10     | kg           | 2         | dough       | I am made with love |
    And I click on "Add New Ingredient"
    And I fill out recipe item with:
      | inclusionable_id_type| percentage |
      | baguette             | 22.5       |
    And I click on "Add New Ingredient"
    And I fill out recipe item with:
       | inclusionable_id_type| percentage |
       | donut                | 44.5       |
    And I click on "Create"
    Then "You have created apple" should be present

  @javascript
  Scenario: As a user, I should be able to edit a recipe and delete another recipe
    When I go to the "recipes" page
    And I click on "Add New Recipe"
    And I fill out recipe form with:
      | name  | mix_size | mix_size_unit | lead_days | recipe_type | note                 |
      | apple | 1.10     | kg            | 2         | dough       | I am made with love  |
    And I click on "Add New Ingredient"
    And I fill out recipe item with:
      | inclusionable_id_type | percentage |
      | baguette              | 22.5       |
    And I click on "Add New Ingredient"
    And I fill out recipe item with:
       | inclusionable_id_type | percentage |
       | donut                 | 44.5       |
    And I click on "Create"
    Then "You have created apple" should be present
    When I am on the edit page for "apple" recipe
    And I delete "donut" ingredient
    And I edit "baguette" baker's percentage
    And I click on "Update"
    Then the recipe item "baguette" should be present
    And the recipe item "donut" should not be present
