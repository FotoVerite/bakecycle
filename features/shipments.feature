Feature: Shipments management
  As a user I should be able to interact with shipments
  Clients have shipments
  There are a lot of shipments

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery clients named "amyavocado" and "francesco"
    And There are "biencuit" shipments with clients named "andysdecaf" and "mandos"

  Scenario: I should be able to filter on the shipment index page
    Given I am on the "shipments" page
    And I filter shipments by the client "mandos"
    Then I should see shipments for the client "mandos"
    Then I should not see shipments for the client "amyavocado"
    And I should see the search term "mandos" preserved in the client search box

  Scenario: I should be able to filter dates on the shipment index page
    Given there are "biencuit" shipments for the past two weeks
    And  I go to the "shipments" page
    And I filter shipments by to and from dates for the past week
    Then I should see a list of shipments for only the past week

  @javascript
  Scenario: I should be able to manage a shipment
    Given I am on the "shipments" page
    And I click on "Add New Shipment"
    And I fill out Shipment form with:
      | client    | date       | route | delivery_fee | note          |
      | mandos | 2015-01-12 | Canal | 10.0         | leave at door |
    And I click on "Create"
    Then "You have created a shipment for mandos." should be present
    And "Payment Due Date" should be present
    And "Total Price: $10.00" should be present

    When I change the shipment's client name to "francesco"
    And I click on "Update"
    Then I should see that the shipment's client name is "francesco"

    When I change the shipment date to ""
    And I click on "Update"
    Then "can't be blank" should be present
    When I change the shipment date to "2015-01-01"
    And I click on "Update"
    Then "You have updated the shipment" should be present

    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation the shipment for "francesco" was deleted
    And the shipment for "francesco" should not be present

  @javascript
  Scenario: I should be able to manage shipment items
    Given I am on the "shipments" page
    And I click on "Add New Shipment"
    And I fill out Shipment form with:
      | client | date       | route | delivery_fee | note          |
      | mandos | 2015-01-12 | Canal | 15           | ask for mando |
    And I click on "Add Product"
    And I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | baguette cookie | 10.00         | 50       |
    And I click on "Add Product" and don't enter any information
    When I click on "Create"
    Then "You have created a shipment" should be present
    And the product "baguette cookie" should be selected

    When I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | donut tart      | 5.00         | 10       |
    And I click on "Update"
    Then "You have updated the shipment" should be present
    And the product "baguette cookie" should not be selected
    And the product "donut tart" should be selected

    When I click on "Add Product"
    And I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | baguette cookie | 10.00         | 50       |
    When I click on "Update"
    Then "You have updated the shipment" should be present
    When I delete "donut tart" shipment item
    And I click on "Update"
    Then "You have updated the shipment" should be present
    And the product "donut tart" should not be selected
