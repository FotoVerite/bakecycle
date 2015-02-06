Feature: Products

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"

  @javascript
  Scenario: As a user, I should be able to create a product
    When I go to the "products" page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | extra_amount| base_price |
      | almond cookies | cookie       | delicious   | 10     | g    | 10          | 1.10       |
    And I click on "Create"
    Then "You have created almond cookies" should be present

  Scenario: As a user, I should be able to view the product index page
    When I go to the "products" page
    Then I should see a list of products including "baguette cookie" and "donut tart"
    When I click on "baguette cookie"
    Then I should see "Product" information about "baguette cookie"

  @javascript
  Scenario: As a user, I should be able to edit a product
    When I am on the edit page for "baguette cookie" product
    And I change the product name to "almond cookie"
    And I click on "Update"
    Then I should see that the product name is "almond cookie"
    When I click on "Back"
    Then I should be on the "Products" index page
    And "almond cookie" should be present
    And "baguette cookie" should not be present

  Scenario: As a user, I should be able to delete a product
    When I am on the edit page for "baguette cookie" product
    And I click on "Delete"
    Then I should see confirmation that the product "baguette cookie" was deleted
    And The product "baguette cookie" should not be present

  @javascript
  Scenario: As a user, I should be able to add a price to a product
    When I go to the "products" page
    Then I should see a list of products including "baguette cookie" and "donut tart"
    When I click on "baguette cookie"
    And I click on "Add New Price"
    And I fill out the price varient form with:
      | price | quantity | date       |
      | 1.99  | 100      | 2014-12-11 |
    And I click on "Update"
    Then "You have updated baguette cookie" should be present

  @javascript
  Scenario: As a user, I should be able to add a price to a new product
    When I go to the "products" page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | extra_amount| base_price |
      | almond cookies | cookie       | delicious   | 10     | g    | 10          | 1.10       |
    And I click on "Add New Price"
    And I fill out the price varient form with:
      | price | quantity | date       |
      | 1.99  | 100      | 2014-12-11 |
    And I click on "Create"
    Then "You have created almond cookies" should be present

  @javascript
  Scenario: As a user, I should be able to add a price to a new product
    When I go to the "products" page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | extra_amount| base_price |
      | almond cookies | cookie       | delicious   | 10     | g    | 10          | 1.10       |
    And I click on "Add New Price"
    And I fill out the price varient form with:
      | price | quantity | date       |
      | 1.99  | 100      | 2014-12-11 |
    And I click on "Add New Price"
    And I fill out the price varient form with:
      | price | quantity | date       |
      | 10.23  | 83      | 2014-12-12  |
    And I click on "Create"
    Then "You have created almond cookies" should be present
    And I click on the last price's remove button
    And I edit the remaining price to "12.00"
    And I click on "Update"
    Then "You have updated almond cookies" should be present
    And there should only be one price

  @javascript
  Scenario: As a user, If I try to create a new product with empty price fields, I should see validation errors
    When I go to the "products" page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | extra_amount| base_price |
      | almond cookies | cookie       | delicious   | 10     | g    | 10          | 1.10       |
    And I click on "Add New Price"
    And I click on "Create"
    Then "Quantity can't be blank" should be present
    And "Effective date can't be blank" should be present

  @javascript
  Scenario: As a user, If I try to edit a product with empty price varient fields, I should see validation errors
    When I go to the "products" page
    When I click on "baguette cookie"
    And I click on "Add New Price"
    And I click on "Update"
    Then "Quantity can't be blank" should be present
    And "Effective date can't be blank" should be present

  @javascript
  Scenario: As a user, If I try to edit a product with empty price varient fields, I should see validation errors
    When I go to the "products" page
    When I click on "baguette cookie"
    And I click on "Add New Price"
    And I fill out the price varient form with:
      | price | quantity | date       |
      | 1.99  | 100      | 2014-12-11 |
    And I click on "Add New Price"
    And I fill out the price varient form with:
      | price | quantity | date        |
      | 10.23  | 100     | 2014-12-11  |
    And I click on "Update"
    And "Identical date and quantity already exist for this product, try a different date." should be present
