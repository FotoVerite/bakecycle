Feature: Inviting Users

  Scenario: As a manager, I can create users for my employees without a password
    Given I am logged in as a user with bakery "manage" access with a bakery called "biencuit"
    When I go to the "users" page
    And I click on "Add New User"
    And I fill out the user with a bakery selection form with:
      | email                  | name    |
      | helloworld@example.com | Foo Bar |
    And I click on "Create"
    Then "An invitation email has been sent to helloworld@example.com" should be present
    And There should be an email to confirm the account

  Scenario: As a manager, I can resend users a confirmation email
    Given I am logged in as an admin
    And There exists a user with an unaccepted invitation
    When I go to the "users" page
    And I send a confirmation email
    Then "An invitation email has been sent to" should be present
    And There should be an email to confirm the account

  Scenario: As a manager, I can't resend users a confirmation email that are confirmed
    Given I am logged in as an admin
    And There exists a user
    When I go to the "users" page
    Then I should not see the link to send a confirmation email

  Scenario: As a manager, I can create a user with a password
    Given I am logged in as a user with bakery "manage" access with a bakery called "biencuit"
    When I go to the "users" page
    And I click on "Add New User"
    And I fill out the user with a bakery selection form with:
      | email                  | name    | password   | password_confirmation |
      | helloworld@example.com | Foo Bar | helloworld | helloworld            |
    And I click on "Create"
    Then "The user helloworld@example.com has been correctly added." should be present
    And There should not be an email sent to the new user

