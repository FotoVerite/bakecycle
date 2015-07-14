Feature: Registrations

  @javascript @stripe_success
  Scenario: Registering as a user
    Given I am a visitor
    And There is bakery plans available
    When I go to the home page
    And I choose small plan
    Then I should be on the registrations page
    And I should see "beta_small" plan selected
    And I submit the registration form with valid data
    Then I should be on the user's dashboard page
    And "Thank you for registering with BakeCycle." should be present
    When I attempt to visit the registrations page again
    Then I should be on the user's dashboard page
    And "You are already registered." should be present

  Scenario: Attempting to register a user that email or bakery already exist
    Given I am a visitor
    And There is bakery plans available
    And There is a bakery named "FitBake"
    And A user with the email "j@dough.com"
    When I go to the new registrations page
    And I submit the registration form with valid data
    Then "has already been taken" should be present
