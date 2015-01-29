Feature: Orders

  Background:
    Given I am logged in as a user
    And There are clients named "starbucks","winecheese" and "arizona"
    And There are orders with clients named "amyavocado","andysdecaf" and "mandos"
    And There are routes named "Canal","Chinatown" and "LES"
    And There are products named "baguette cookie","donut tart" and "croissant sandwich"

  @javascript
  Scenario: As a user, I should be able to view orders index
    When I go to the "orders" page
    Then I should see a list of orders including clients named "amyavocado","andysdecaf" and "mandos"
    When I click on "amyavocado"
    Then I should be redirected to "amyavocado" page

  @javascript
  Scenario: As a user, I should be able to add an standing order
    When I go to the "orders" page
    And I click on "Add New Order"
    And I fill out Order form with:
      | order_type | start_date | end_date   | route | client  | note          |
      | standing   | 2014-12-12 | 2014-12-20 | Canal | arizona | Ring the door |
    And I fill out the order item form with:
      | product         | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | baguette cookie | 10     | 1       | 2         | 3        | 4      | 5        | 3      |
    And I click on "Create"
    Then "You have created a standing order for arizona." should be present

  @javascript
  Scenario: As a user, I should be able to add a temporary order
    When I go to the "orders" page
    And I click on "Add New Order"
    And I fill out temporary order form with:
      | order_type | start_date | route | client  | note |
      | temporary  | 2014-12-12 | Canal | arizona | Ring the door |
    And I fill out the temporary order item form with:
      | product         | friday |
      | baguette cookie | 4      |
    And I click on "Create"
    Then "You have created a temporary order for arizona." should be present

  @javascript
  Scenario: As a user, I should be able to delete an order
    When I am on the edit page for "amyavocado" order
    And I click on "Delete"
    And I confirm popup
    Then I should be redirected to the Orders page
    And "amyavocado" should not be present

  @javascript
  Scenario: As a user, I should be able to add multiple order item to a order
    When I am on the edit page for "amyavocado" order
    And I click on "Add New Order Item"
    And I fill out the order item form with:
      | product         | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | baguette cookie | 10     | 1       | 2         | 3        | 4      | 5        | 3      |
    And I click on "Update"
    Then "You have updated the standing order for amyavocado" should be present

  @javascript
  Scenario: As a user, I should be able to edit an order and delete an order item on a order
    When I am on the edit page for "amyavocado" order
    And I fill out the order item form with:
      | product         | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | baguette cookie | 10     | 1       | 2         | 3        | 4      | 5        | 3      |
    And I click on "Add New Order Item"
    And I fill out the order item form with:
      | product    | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | donut tart | 9      | 5       | 6         | 8        | 9      | 8        | 4      |
    And I click on "Update"
    Then "You have updated the standing order for amyavocado" should be present
    When I delete "donut tart" order item
    And I edit the order item "baguette cookie" "Mon" quantity with "10"
    And I click on "Update"
    Then the order item "baguette cookie" should be present
    And the order item "donut tart" should not be present

    @javascript
    Scenario: As a user, I should see an error if I click update after I delete the last order item. Then I should be able to add an order item, and see 2 order items.
    When I am on the edit page for "amyavocado" order
    And I click on "X"
    And I click on "Update"
    Then "You must choose a product before saving" should be present
    When I click on "Add New Order Item"
    And I fill out the order item form with:
      | product    | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | donut tart | 9      | 5       | 6         | 8        | 9      | 8        | 4      |
    And I click on "Update"
    Then "X" should be present "2" times

