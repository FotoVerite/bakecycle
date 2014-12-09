Feature: Products Index

  Scenario: As a visitor, I should be able to create a product
    Given I am a visitor
    When I go to the products page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | extra_amount|
      | almond cookies | cookie       | delicious   | 10     | g    | 10          |
    And I click on "Create"
    Then "You have created almond cookies" should be present

  Scenario: As a visitor, I should be able to view the product index page
    Given I am a visitor
    And There are products named "baguette cookie","donut tart" and "croissant sandwich"
    When I go to the products page
    Then I should see a list of products including "baguette cookie", "donut tart" and "croissant sandwich"
    When I click on "baguette cookie"
    Then I should be redirected to a product page

  Scenario: As a visitor, I should be able to edit a product
    Given I am a visitor
    And There are products named "baguette cookie","donut tart" and "croissant sandwich"
    When I am on the edit page for "baguette cookie" product
    And I change the product name to "almond cookie"
    And I click on "Update"
    Then I should see that the product name is "almond cookie"
    When I click on "Back"
    Then I should be on the "Products" index page
    And "almond cookie" should be present
    And "baguette cookie" should not be present

  Scenario: As a visitor, I should be able to delete a product
    Given I am a visitor
    And There are products named "baguette cookie","donut tart" and "croissant sandwich"
    When I am on the edit page for "baguette cookie" product
    And I click on "Delete"
    Then I should be redirected to the products page
    And "baguette cookie" should not be present

  @javascript
  Scenario: As a visitor, I should be able to add a price to a product
    Given I am a visitor
    And There are products named "baguette cookie","donut tart" and "croissant sandwich"
    When I go to the products page
    Then I should see a list of products including "baguette cookie", "donut tart" and "croissant sandwich"
    When I click on "baguette cookie"
    And I click on "Add Price"
    And I fill out the product price form with:
      | price | quantity | date       |
      | 1.99  | 100      | 2014-12-11 |
    And I click on "Update"
    Then "You have updated baguette cookie" should be present

  @javascript
  Scenario: As a visitor, I should be able to add a price to a new product
    Given I am a visitor
    When I go to the products page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | extra_amount|
      | almond cookies | cookie       | delicious   | 10     | g    | 10          |
    And I click on "Add Price"
    And I fill out the product price form with:
      | price | quantity | date       |
      | 1.99  | 100      | 2014-12-11 |
    And I click on "Create"
    Then "You have created almond cookies" should be present

  @javascript
  Scenario: As a visitor, I should be able to add a price to a new product
    Given I am a visitor
    When I go to the products page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | extra_amount|
      | almond cookies | cookie       | delicious   | 10     | g    | 10          |
    And I click on "Add Price"
    And I fill out the product price form with:
      | price | quantity | date       |
      | 1.99  | 100      | 2014-12-11 |
    And I click on "Add Price"
    And I fill out a second product price form with:
      | price | quantity | date       |
      | 10.23  | 83      | 2014-12-12  |
    And I click on "Create"
    Then "You have created almond cookies" should be present
    And I click on the last price's remove button
    And I edit the remaining price to "12.00"
    And I click on "Update"
    Then "You have updated almond cookies" should be present
    And there should only be one price
