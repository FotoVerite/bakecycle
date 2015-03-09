Feature: DemoCreator

  Scenario: As an Admin, I should be able to create bakery demo-data when creating a bakery
    Given I am logged in as an admin
    Given I am on the "bakeries" page
    When I click on "Add New Bakery"
    And I fill out Bakery form with:
      | name   | email            | phone        | street        | city | state | zipcode |
      | Mandos | test@example.com | 999-888-7777 | 123 Example St. | Bake | NY    | 10001   |
    And I click on "Create"
    Then "Mandos" bakery should have demodata in the database
