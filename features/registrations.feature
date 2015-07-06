Feature: Registrations

  @javascript
  Scenario: Registering as a user
    Given I am a visitor
    And There is bakery plans available
    When I go to the new registrations page
    And I fill out the registrations form with:
      | plan       | first | last  | bakery_name | email       | password  |
      | beta_small | john  | dough | FitBake     | j@dough.com | foobarbaz |
    And I click on "Join BakeCycle"
    Then I should be on the user's dashboard page
    And "Thank you for registering with BakeCycle." should be present
    When I attempt to visit the registrations page again
    Then I should be on the user's dashboard page
    And "You are already registered." should be present

  @javascript
  Scenario: Registerting as a user from the homepage
    Given I am a visitor
    And There is bakery plans available
    When I go to the home page
    And I choose small plan on pricing section of the homepage
    Then I should be on the registrations page
    And I should see "beta_small" plan selected
    When I fill out the rest of the registrations form with:
      | first | last  | bakery_name | email       | password  |
      | john  | dough | FitBake     | j@dough.com | foobarbaz |
    And I click on "Join BakeCycle"
    Then I should be on the user's dashboard page
    And "Thank you for registering with BakeCycle" should be present

  Scenario: Attempting to register a user that email or bakery already exist
    Given I am a visitor
    And There is bakery plans available
    And There is a bakery named "FitBake"
    And A user with the email "j@dough.com"
    When I go to the new registrations page
    And I fill out the registrations form with:
     | plan       | first | last  | bakery_name | email       | password  |
     | beta_small | john  | dough | FitBake     | j@dough.com | foobarbaz |
    And I click on "Join BakeCycle"
    Then "has already been taken" should be present
