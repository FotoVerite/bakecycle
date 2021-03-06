Feature: Products

  @javascript
  Scenario: As a user with full access to products
    Given I am logged in as an user with product "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    When I go to the "products" page
    Then I should see a list of products including "baguette cookie" and "donut tart"
    When I click on "baguette cookie"
    Then I should see "Product" information about "baguette cookie"

    When I go to the "products" page
    And I click on "Add New Product"
    And I fill out product form with:
      | name           | product_type | description | weight | unit | over_bake | base_price | sku             |
      | almond cookies | cookie       | delicious   | 10     | g    | 10        | 1.10       | abc-123-xyz-890 |
    And I fill out the price variant form with:
      | price | quantity |
      | 10.23 |          |
    And I click on "Create"
    Then "can't be blank" should be present
    And I fill out the price variant form with:
      | price | quantity |
      | 10.23 | 100      |

    And I click on "Create"
    Then "You have created almond cookies" should be present

    When I change the product name to "sugar cookie"
    And I click on "Update"
    Then I should see that the product name is "sugar cookie"

    And I fill out the price variant form with:
      | price  | quantity |
      | 10.23  | 83       |
    And I click on "Update"
    Then "You have updated sugar cookie" should be present
    And I click on the last price's remove button
    And I edit the remaining price to "12.00"
    And I click on "Update"
    Then "You have updated sugar cookie" should be present
    And there should only be one price

    When I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the product "sugar cookie" was deleted
    And The product "sugar cookie" should not be present

  Scenario: As a user with read access to products
    Given I am logged in as an user with product "read" access with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    When I go to the "products" page
    Then I should see a list of products including "baguette cookie" and "donut tart"
    When I click on "baguette cookie"
    Then "You are not authorized to access this page." should be present

  Scenario: As a user with none access to products
    Given I am logged in as an user with product "none" access with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    When I go to the "products" page
    Then "You are not authorized to access this page." should be present

  @javascript
  Scenario: As a user with manage access, I can set a price variant for a client
    Given I am logged in as an user with product "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And "Boom Headshot" is a client of "biencuit"
    When I go to the "products" page
    Then I should see a list of products including "baguette cookie" and "donut tart"
    When I click on "baguette cookie"
    And I fill out the price variant form with:
      | price  | quantity | client        |
      | 10.23  | 83       | Boom Headshot |
    And I click on "Update"
    Then "You have updated baguette cookie" should be present

