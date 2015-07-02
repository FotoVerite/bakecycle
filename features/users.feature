Feature: Users

  Scenario: As a user with full access
    Given I am logged in as an user with manage access
    And there is a user named "Andrew"
    When I go to the "users" page
    Then I should not see a bakeries column
    Then I should see a list of users including "Andrew"
    When I click on "Andrew"
    Then I should information about the user "Andrew"

    When I go to the "users" page
    And I click on "Add New User"
    And I fill out User form with:
      | email                | name     | user_permission |
      | new_user@example.com | John Doe | None            |
    And I click on "Create"
    Then "An invitation email has been sent to new_user@example.com" should be present

  Scenario: Editing a user with full access
    Given I am logged in as an user with manage access
    And there is a user named "Andrew"
    And there is a user named "John Doe"
    When I edit the user "John Doe"
    And I change the user name to "James" and his user permission to "Manage"
    And I click on "Update"
    Then I should see that the user name is "James"

    When I edit the user "Andrew"
    And I click on "Delete"
    Then I should see confirmation that the user "Andrew" was deleted
    And The user "Andrew" should not be present

    When I go to my user's edit page
    And I edit my name to "Harry"
    And I click on "Update"
    Then "You have updated Harry." should be present
    Then I should see that the user name is "Harry"

  Scenario: As a user with read only access
    Given I am logged in as an user with read access
    And there is a user named "Andrew"
    When I go to the "users" page
    Then I should not see a bakeries column
    Then I should see a list of users including "Andrew"
    When I click on "Andrew"
    Then "You are not authorized to access this page." should be present
    When I attempt to create a new user
    Then "You are not authorized to access this page." should be present

    When I go to my user's edit page
    And I edit my name to "Harry"
    And I click on "Update"
    Then "You have updated Harry." should be present
    Then I should see that the user name is "Harry"

  Scenario: As a user with none access
    Given I am logged in as an user with none access
    When I attempt to create a new user
    Then "You are not authorized to access this page." should be present
    When I go to my user's edit page
    And I edit my name to "Harry"
    And I click on "Update"
    Then "You have updated Harry." should be present
    Then I should see that the user name is "Harry"
