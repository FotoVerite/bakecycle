Feature: Recipes

  @javascript
  Scenario: As a user with full access to recipes
    Given I am logged in as an user with product "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery recipes named "baguette" and "donut"
    And There are "biencuit" bakery ingredients named "celery" and "almond"

    When I am on the "recipes" page
    Then I should see a list of recipes including "baguette" and "donut"
    When I click on "baguette"
    Then I should see "Recipe" information about "baguette"

    Given I am on the "recipes" page
    When I click on "Add New Recipe"
    And I fill out recipe form with:
      | name  | mix_size | mix_size_unit| lead_days | recipe_type | note                |
      | apple |  1.10    | kg           | 2         | dough       | I am made with love |
    And I click on "Create"
    Then "You have created apple" should be present

    When I change the recipe name to "danish"
    And I click on "Update"
    Then I should see that the recipe name is "danish"

    When I click on "Add New Ingredient"
    And I fill out recipe item with:
       | inclusionable_id_type | percentage |
       | almond                | 22.5       |
    When I click on "Add New Ingredient"
    And I click on "Update"
    Then "You have updated danish" should be present

    When I click on "Delete"
    And I confirm popup
    Then I should see confirmation the recipe "danish" was deleted
    And the recipe "danish" should not be present

    Given I am on the "recipes" page
    When I click on "Add New Recipe"
    And I fill out recipe form with:
      | name  | mix_size | mix_size_unit| lead_days | recipe_type | note                |
      | pears |  1.10    | kg           | 2         | dough       | I am made with love |
    When I click on "Add New Ingredient"
    And I fill out recipe item with:
       | inclusionable_id_type | percentage |
       | almond                | 22.5       |
    When I click on "Add New Ingredient"
    And I click on "Create"
    Then "You have created pear" should be present

    Scenario: As a user with read access to recipes
      Given I am logged in as an user with product "read" access with a bakery called "biencuit"
      And There are "biencuit" bakery recipes named "baguette" and "donut"
      And There are "biencuit" bakery ingredients named "celery" and "almond"
      When I am on the "recipes" page
      Then I should see a list of recipes including "baguette" and "donut"
      When I click on "baguette"
      Then "You are not authorized to access this page." should be present

    Scenario: As a user with none access to recipes
      Given I am logged in as an user with product "none" access with a bakery called "biencuit"
      And There are "biencuit" bakery recipes named "baguette" and "donut"
      And There are "biencuit" bakery ingredients named "celery" and "almond"
      When I attempt to visit the "recipes" page
      Then "You are not authorized to access this page." should be present


