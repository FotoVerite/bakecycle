Feature: Delivery Lists

  Background:
    Given Theres a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery clients named "amyavocado" and "francesco"
    And There are "biencuit" shipments with clients named "andysdecaf" and "mandos"
    And there are "biencuit" shipments for the past two weeks

  @javascript
  Scenario: As a user with full access to shipping routes
    Given I am logged in as an user apart of "biencuit" bakery with shipping "manage" access
    When I am on the "delivery_lists" page
    And I click on "Print Delivery List"
    Then I should see the pdf generated page with "delivery_lists" included in the url

  @javascript
  Scenario: As a user with read access to shipping routes
    Given I am logged in as an user apart of "biencuit" bakery with shipping "read" access
    When I am on the "delivery_lists" page
    And I click on "Print Delivery List"
    Then I should see the pdf generated page with "delivery_lists" included in the url

  @javascript
  Scenario: As a user with none access to shipping routes
    Given I am logged in as an user apart of "biencuit" bakery with shipping "none" access
    When I attempt to visit the "delivery_lists" page
    Then "You are not authorized to access this page." should be present
