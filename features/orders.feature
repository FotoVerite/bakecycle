Feature: Orders

  @javascript
  Scenario: As a user with full access views orders missing shipments
    Given I am logged in as an user with client "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery orders without shipments with clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    When I go to the "orders" page
    Then I should see a list of missing shipments including clients named "andysdecaf" and "mandos"
    When I click the order "andysdecaf"
    Then I should see the callout "This order is missing"


  @javascript
  Scenario: As a user with full access to orders
    Given I am logged in as an user with client "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery orders with clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"

    When I go to the "orders" page
    Then I should see a list of orders including clients named "andysdecaf" and "mandos"
    When I click the order "andysdecaf"
    Then I should see order information about "andysdecaf"

    When I go to the "orders" page
    And I click on "Add New Order"
    And I fill out Order form with:
      | order_type | start_date | end_date   | route | client | note          |
      | standing   | 2014-11-11 | 2014-12-20 | Canal | mandos | Ring the door |
    And I fill out the order item form with:
      | product         | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | baguette cookie | 10     | 1       | 2         | 3        | 4      | 5        | 3      |
    And I click on the "Add" link
    And I click on "Create"
    Then "You have created a standing order for mandos." should be present
    Then "baguette cookie" should be present
    When I click on "Copy Order"
    When I edit the order form with:
      | order_type | start_date |
      | standing  | 2014-11-12 |
    And I click on "Create"
    And I click on "Create and Override Existing Order"
    And I confirm popup
    Then "You have created a standing order for mandos." should be present
    When I click on "Copy Order"
    When I edit the order form with:
      | order_type | start_date |
      | temporary  | 2014-11-12 |
    And I click on "Create"
    Then "You have created a temporary order for mandos." should be present

    When I am on the edit page for "andysdecaf" order
    And I fill out the order item form with:
      | product         | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | baguette cookie | 10     | 1       | 2         | 3        | 4      | 5        | 3      |
    And I click on the "Add" link
    And I fill out the order item form with:
      | product    | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | donut tart | 9      | 5       | 6         | 8        | 9      | 8        | 4      |
    And I click on "Update"
    Then "You have updated the standing order for andysdecaf" should be present
    And "donut tart" should be present
    When I delete the "donut tart" order item
    And I edit the order item "baguette cookie" "Mon" quantity with "10"
    And I click on "Update"
    Then the order item "baguette cookie" should be present
    And the order item "donut tart" should not be present

    When I am on the edit page for "andysdecaf" order
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation that the "standing" order "andysdecaf" was deleted
    And The order "andysdecaf" should not be present

    When I am on the edit page for "mandos" order
    And I fill out the order item form with:
      | product    | monday | tuesday | wednesday | thursday | friday | saturday | sunday |
      | donut tart | 9      | 5       | 6         | 8        | 9      | 8        | 4      |
    And I click on "Update"
    Then "remove_order_item" button should be present "3" times

  Scenario: As a user with read access to orders
    Given I am logged in as an user with client "read" access with a bakery called "biencuit"
    And There are "biencuit" bakery clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery orders with clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"

    When I go to the "orders" page
    Then I should see a list of orders including clients named "andysdecaf" and "mandos"
    When I click the order "andysdecaf"
    Then "You are not authorized to access this page." should be present

  Scenario: As a user with none access to orders
    Given I am logged in as an user with client "none" access with a bakery called "biencuit"
    And There are "biencuit" bakery clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery orders with clients named "andysdecaf" and "mandos"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"

    When I go to the "orders" page
    Then "You are not authorized to access this page." should be present
