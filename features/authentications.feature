Feature: Authentication

  Scenario: As a visitor, I can login and logout
    Given I am a visitor
    And There is a user with email "johndoe@example.com" and password "password1"
    And I go to the home page
    When I click on "Log in"
    And I fill in user form with:
      | email               | password  |
      | johndoe@example.com | password1 |
    And I click on "Log in"
    Then "Signed in successfully" should be present
