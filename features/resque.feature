Feature: Resque

  Scenario: As a user without admin priveledge, I cannot view resque
    Given I am logged in as a user
    And I go to the "dashboard" page
    Then "resque" link should not be on the side nav

  Scenario: As a admin, I can view resque dashboard to view my workers
    Given I am logged in as an admin
    When I go to the "resque_server" page
    Then "Queues" should be present
