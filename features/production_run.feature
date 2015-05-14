  Feature: Production Run Editing
  As a user I should be able to find and edit production runs

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And there is a "biencuit" production run

  @javascript
  Scenario: Find and edit and add run items to a production run from production runs
    Given there is a run item for a "biencuit" production run
    And I am on the Production Runs page
    Then I should see the date for my production run
    When I click on that production run row
    Then "Editing Production Run" should be present

  @javascript
  Scenario: Find and edit and add run items to a production run from print recipes
    Given there is a run item for a "biencuit" production run
    And I am on the Print Recipes page
    When I click on "Add Product"
    And I change the overbake quantity on the existing run item
    And I fill out run item form with:
      | product         | overbake_quantity|
      | donut tart      | 15               |
    And I click on "Add Product" and don't enter any information
    When I click on "Update"
    Then "Successfully updated" should be present
    And "baguette cookie" should be present
    When I click an a run item delete button on the donut
    Then "donut tart" should not be present
    When I click on "Update"
    Then "donut tart" should not be present
    And "baguette cookie" should be present
    Given "biencuit" has clients and active orders
    And I am on the Print Recipes page
    When I search for tomorrow's recipe runs
    Then I should see a warning that I am seeing a projection
    Then I should rows of projected product quantities

  @javascript
  Scenario: Not allowed to add same product more than once
    Given there is a run item for a "biencuit" production run
    And I am on the Print Recipes page
    When I click on "Add Product"
    And I fill out run item form with:
      | product         | overbake_quantity|
      | donut tart      | 15               |
    And I click on "Add Product"
    And I fill out run item form with:
      | product         | overbake_quantity|
      | donut tart      | 15               |
    And I click on "Update"
    Then "Cannot add same product more than once" should be present
    When I click on "Add Product"
    And I fill out run item form with:
      | product         | overbake_quantity|
      | donut tart      | 15               |
    And I click on "Update"
    Then "Successfully updated" should be present

  @javascript
  Scenario: Resetting production runs
    Given there is a run item and shipment item for a "biencuit" production run
    And I am on the Print Recipes page
    And I change the shipment item product quantity to "99"
    When I click on "Reset"
    When I accept in the confirm box
    Then "Reset Complete" should be present
    And the product quantity should be the same as the shipment item
