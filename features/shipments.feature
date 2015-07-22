Feature: Shipments management
  As a user I should be able to interact with shipments
  Clients have shipments
  There are a lot of shipments

  @javascript
  Scenario: As a user with full access to shipments
    Given I am logged in as an user with client "manage" access with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery clients named "amyavocado" and "francesco"
    And There are "biencuit" shipments with clients named "andysdecaf" and "mandos"
    And there are "biencuit" shipments for the past two weeks

    When I am on the "shipments" page
    And I filter shipments by the client "mandos"
    Then I should see shipments for the client "mandos"
    Then I should not see shipments for the client "amyavocado"

    When I am on the "shipments" page
    And I filter shipments by to and from dates for the past week
    Then I should see a list of shipments for only the past week

    When I am on the "shipments" page
    And I click on "Add New Invoice"
    And I fill out Shipment form with:
      | client | date       | route | delivery_fee | note          |
      | mandos | 2015-01-12 | Canal | 10.0         | leave at door |
    And I click on "Create"
    Then "You have created an invoice for mandos." should be present
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
    Then "You have updated the invoice" should be present

    And I click on "Delete"
    And I confirm popup
    Then I should see confirmation the shipment for "francesco" was deleted
    And the shipment for "francesco" should not be present

    When I am on the "shipments" page
    And I click on "Add New Invoice"
    And I fill out Shipment form with:
      | client | date       | route | delivery_fee | note          |
      | mandos | 2015-01-15 | Canal | 15           | ask for mando |
    And I click on "Add Product"
    And I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | baguette cookie | 10.00         | 50       |
    And I click on "Add Product" and don't enter any information
    When I click on "Create"
    Then "You have created an invoice" should be present
    And the product "baguette cookie" should be selected

    When I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | donut tart      | 5.00         | 10       |
    And I click on "Update"
    Then "You have updated the invoice" should be present
    And the product "baguette cookie" should not be selected
    And the product "donut tart" should be selected

    When I click on "Add Product"
    And I fill out Shipment Item form with:
      | product         | product_price | quantity |
      | baguette cookie | 10.00         | 50       |
    When I click on "Update"
    Then "You have updated the invoice" should be present
    When I delete "donut tart" shipment item
    And I click on "Update"
    Then "You have updated the invoice" should be present
    And the product "donut tart" should not be selected

    When I am on the "packing_slips" page
    Then I should see a table of shipping information
    When I click on "Print Packing Slips"
    Then I should be on the "Packing Slips" index page

  @javascript
  Scenario: As a user with read access to shipments
    Given I am logged in as an user with client "read" access with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery clients named "amyavocado" and "francesco"
    And There are "biencuit" shipments with clients named "andysdecaf" and "mandos"
    And there are "biencuit" shipments for the past two weeks

    When I am on the "shipments" page
    Then "Add New Invoice" should not be present
    And "Print Invoices" should be present
    And "Export CSV" should be present
    And "Export QuickBooks" should be present

    When I attempt to edit the first shipment on the page
    Then "You are not authorized to access this page." should be present

  @javascript
  Scenario: As a user with none access to shipments
    Given I am logged in as an user with client "none" access with a bakery called "biencuit"
    And There are "biencuit" bakery products named "baguette cookie" and "donut tart"
    And There are "biencuit" bakery routes named "Canal" and "Chinatown"
    And There are "biencuit" bakery clients named "amyavocado" and "francesco"
    And There are "biencuit" shipments with clients named "andysdecaf" and "mandos"
    And there are "biencuit" shipments for the past two weeks

    When I attempt to visit the "shipments" page
    Then "You are not authorized to access this page." should be present


