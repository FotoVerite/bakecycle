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

  Scenario: I should be able to view shipments
    Given There are "30" shipments for "mandos"
    And I am on the "shipments" page
    Then I should see shipments for "mandos"
    When I click on "Next"
    Then I should see shipments for "mandos"

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
  Scenario: I should be able to add a shipment
    Given I am on the "shipments" page
    And I click on "Add New Shipment"
    And I fill out Shipment form with:
      | client    | date       | route |
      | francesco | 2015-01-12 | Canal |
    And I click on "Create"
    Then "You have created a shipment for francesco." should be present
    And "Payment Due Date" should be present

  @javascript
  Scenario: I should be able to edit a shipment
    When I am on the shipment edit page for the client "mandos"
    And I change the shipment's client name to "francesco"
    And I click on "Update"
    Then I should see that the shipment's client name is "francesco"
    When I click on "Back"
    Then I should be on the "Shipments" index page
    And "francesco" should be present
    And I should not see shipments for the client "mandos"

  @javascript
  Scenario: When I edit the shipment with invalid data I should an error
    When I am on the shipment edit page for the client "mandos"
    And I change the shipment date to ""
    And I click on "Update"
    Then "can't be blank" should be present
    When I change the shipment date to "2015-01-01"
    And I click on "Update"
    Then "You have updated the shipment" should be present

  @javascript
  Scenario: I should be able to delete a shipment
    When I am on the shipment edit page for the client "mandos"
    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation the shipment for "mandos" was deleted
    And the shipment for "mandos" should not be present

  @javascript
  Scenario: I should be able to add shipment items to a shipment
    Given I am on the "shipments" page
    And I click on "Add New Shipment"
    And I fill out Shipment form with:
      | client | date       | route |
      | mandos | 2015-01-12 | Canal |
    And I click on "Add New Shipment Item"
    And I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | baguette cookie | 10.00         | 50       |
    When I click on "Create"
    Then "You have created a shipment" should be present
    And "baguette cookie" should be present

  @javascript
  Scenario: I should be able to edit a shipment item
    When I am on the edit page for "andysdecaf" shipment
    And I click on "Add New Shipment Item"
    And I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | baguette cookie | 10.00         | 50       |
    When I click on "Update"
    Then "You have updated the shipment" should be present
    When I replace "baguette cookie" product name with "donut tart"
    And I click on "Update"
    Then "You have updated the shipment" should be present
    And the shipment item "baguette cookie" should not be present
    And the shipment item "donut tart" should be present

  @javascript
  Scenario: I should be able to edit a shipment item
    When I am on the edit page for "andysdecaf" shipment
    And I click on "Add New Shipment Item"
    And I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | baguette cookie | 10.00         | 50       |
    When I click on "Update"
    Then "You have updated the shipment" should be present
    When I delete "baguette cookie" shipment item
    And I click on "Update"
    Then "You have updated the shipment" should be present
    And the shipment item "baguette cookie" should not be present

