Feature: Bakery

  @javascript
  Scenario: As an Admin, I can manage bakeries
    Given I am logged in as an admin
    And there are bakeries named "Biencuit","Grumpy" and "Wonder"
    And I am on the "bakeries" page
    Then I should see a list of bakeries including "Biencuit", "Grumpy" and "Wonder"
    When I click on "Wonder"
    Then I should see "Bakery" information about "Wonder"

    Given I am on the "bakeries" page
    When I click on "Add New Bakery"
    And I fill out Bakery form with valid data
    And I upload my Bakery logo
    And I click on "Create"
    Then "You have created" should be present

    And I am on the edit page for "Grumpy" bakery
    When I change the bakery name to "Cheeky's"
    And I click on "Update"
    Then I should see that the bakery name is "Cheeky's"
    When I click on "Back"
    Then I should be on the "Bakeries" index page
    And "Cheeky's" should be present
    And "Grumpy" should not be present

    And I am on the edit page for "Wonder" bakery
    When I click on "Delete"
    And I confirm popup
    Then I should see confirmation the bakery was deleted
    And the bakery "Wonder" should not be present

  Scenario: As a User, with manage access to my bakery
    Given I am logged in as an user with bakery "manage" access with a bakery called "biencuit"
    When I visit my bakery
    Then "Update" button should be present
    And "Delete" link should not be present

    When I change the bakery name to "Cheeky's"
    And I click on "Update"
    Then I should see that the bakery name is "Cheeky's"

  Scenario: As a User, with read access to my bakery
    Given I am logged in as an user with bakery "read" access with a bakery called "biencuit"
    When I visit my bakery
    Then "Update" button should not be present
    And "Delete" link should not be present

  Scenario: As a User, with none access to my bakery
    Given I am logged in as an user with bakery "none" access with a bakery called "biencuit"
    And I am on the "bakeries" page
    Then "You are not authorized to access this page." should be present
