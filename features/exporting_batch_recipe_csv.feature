Feature: Exporting Batch Recipes as a CSV

  Background:
    Given I am logged in as a user with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And there is a "biencuit" production run

  Scenario: As a user with production manage permission, I can export a batch
    Given I am on the Batch Recipes page
    And I click on "Export as CSV"
    Then I should see the csv
