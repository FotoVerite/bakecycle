Feature: Shipments

  Background:
    Given I am logged in as a user
    And There are products named "baguette cookie","donut tart" and "croissant sandwich"
    And There are clients named "starbucks","winecheese" and "arizona"
    And There are routes named "Canal","Chinatown" and "LES"
    And There are shipments with clients named "amyavocado","andysdecaf" and "mandos"

  Scenario: As a user, I should be able to view shipments
    When I go to the "shipments" page
    Then I should see a list of shipments including clients named "amyavocado","andysdecaf" and "mandos"
    When I click on "amyavocado"
    Then I should be redirected to "amyavocado" page

  @javascript
  Scenario: As a user, I should be able to add a shipment
    When I go to the "shipments" page
    And I click on "Add New Shipment"
    And I fill out Shipment form with:
      | client       | shipment_date    | route  |
      | amyavocado   | 2015-1-12        | Canal  |
    And I click on "Create"
    Then "You have created a shipment for amyavocado." should be present
    And "Payment Due Date" should be present

  @javascript
  Scenario: As a user, I should be able to edit a shipment
    When I am on the shipment edit page for the client "amyavocado"
    And I change the shipment's client name to "starbucks"
    And I click on "Update"
    Then I should see that the shipment's client name is "starbucks"
    When I click on "Back"
    Then I should be on the "Shipments" index page
    And "starbucks" should be present
    And "amyavocado" should not be present

  @javascript
  Scenario: As a user, I should be able to delete a shipment
    When I am on the shipment edit page for the client "amyavocado"
    And I click on "Delete"
    And I confirm popup
    Then I should be redirected to the Shipments page
    And "amyavocado" should not be present

  @javascript
  Scenario: As a user, I should be able to edit a shipment's date
    When I am on the shipment edit page for the client "amyavocado"
    And I change the shipment date to ""
    And I click on "Update"
    Then "can't be blank" should be present
    When I change the shipment date to "2015-01-01"
    And I click on "Update"
    Then "You have updated the shipment" should be present

  @javascript
  Scenario: As a user, I should be able to add shipment items to a shipment
    When I go to the "shipments" page
    And I click on "Add New Shipment"
    And I fill out Shipment form with:
      | client       | shipment_date    | route  |
      | mandos       | 2015-1-12        | Canal  |
    And I click on "Add Shipment Item"
    And I fill out Shipment Item form with:
      | product           | price_per_item    | quantity   |
      | baguette cookie   | 10.00             | 50         |
    When I click on "Create"
    Then "You have created a shipment" should be present
    And "baguette cookie" should be present

  @javascript
  Scenario: As a user, I should be able to edit a shipment item
    When I am on the edit page for "andysdecaf" shipment
    And I click on "Add Shipment Item"
    And I fill out Shipment Item form with:
      | product           | price_per_item    | quantity   |
      | baguette cookie   | 10.00             | 50         |
    When I click on "Update"
    Then "You have updated the shipment" should be present
    When I replace "baguette cookie" product name with "donut tart"
    And I click on "Update"
    Then "You have updated the shipment" should be present
    And the shipment item "baguette cookie" should not be present
    And the shipment item "donut tart" should be present

  @javascript
  Scenario: As a user, I should be able to edit a shipment item
    When I am on the edit page for "andysdecaf" shipment
    And I click on "Add Shipment Item"
    And I fill out Shipment Item form with:
      | product           | price_per_item    | quantity   |
      | baguette cookie   | 10.00             | 50         |
    When I click on "Update"
    Then "You have updated the shipment" should be present
    When I delete "baguette cookie" shipment item
    And I click on "Update"
    Then "You have updated the shipment" should be present
    And the shipment item "baguette cookie" should not be present
