Feature: Orders

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery orders with clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"

  Scenario: As a user, I need to be able to view orders index
    When I go to the "orders" page
    Then I should see a list of orders including clients named "andysdecaf" and "mandos"
    When I click the order "andysdecaf"
    Then I should see order information about "andysdecaf"

  @javascript
  Scenario: As a user I need to be able to add an standing order and duplicate this order
    When I go to the "orders" page
    And I click on "Add New Order"
    And I fill out Order form with:
      | order_type | start_date | end_date   | route | client | note          |
      | standing   | 2014-11-11 | 2014-12-20 | Canal | mandos | Ring the door |
    And I fill out the order item form with:
      | product         | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | baguette cookie | 10     | 1       | 2         | 3        | 4      | 5        | 3      |
    And I click on "Add Product" and don't enter any information
    And I click on "Create"
    Then "You have created a standing order for mandos." should be present
    When I click on "Create New Order From This Order"
    And I click on "Create"
    Then "This order overlaps with ids" should be present
    When I edit the order form with:
      | order_type | start_date |
      | temporary  | 2014-11-11 |
    And I click on "Create"
    Then "You have created a temporary order for mandos." should be present
    When I go to the "orders" page

  @javascript
  Scenario: As a user I need to be able to add a temporary order
    When I go to the "orders" page
    And I click on "Add New Order"
    And I fill out temporary order form with:
      | order_type | start_date | route | client     | note |
      | temporary  | 2014-12-12 | Canal | andysdecaf | Ring the door |
    And I fill out the temporary order item form with:
      | product         | friday |
      | baguette cookie | 4      |
    And I click on "Create"
    Then "You have created a temporary order for andysdecaf." should be present

  @javascript @firefox
  Scenario: As a user I need to be able to edit and delete an order and its items
    When I am on the edit page for "andysdecaf" order
    And I fill out the order item form with:
      | product         | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | baguette cookie | 10     | 1       | 2         | 3        | 4      | 5        | 3      |
    And I click on "Add Product"
    And I fill out the order item form with:
      | product    | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | donut tart | 9      | 5       | 6         | 8        | 9      | 8        | 4      |
    And I click on "Update"
    Then "You have updated the standing order for andysdecaf" should be present
    When I delete "donut tart" order item
    And I edit the order item "baguette cookie" "Mon" quantity with "10"
    And I click on "Update"
    Then the order item "baguette cookie" should be present
    And the order item "donut tart" should not be present

    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the "standing" order "andysdecaf" was deleted
    And The order "andysdecaf" should not be present

  @javascript
  Scenario: As a user I need to have a forgiving time adding products
    When I am on the edit page for "andysdecaf" order
    And I click on "X"
    And I click on "Update"
    When I click on "Add Product"
    And I fill out the order item form with:
      | product    | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | donut tart | 9      | 5       | 6         | 8        | 9      | 8        | 4      |
    And I click on "Update"
    Then "remove_order_item" button should be present "2" times
