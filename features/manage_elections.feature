
Feature: Manage elections
  In order to set up, monitor, and manage elections
  As an administrator
  I want to create, edit, list, and delete elections

  Scenario: Register new election
    Given I logged in as the administrator
    And I am on the new election page
    When I fill in "Name" with "2008 Election"
    And I fill in "Starts at" with "2008-11-04 00:00:01"
    And I fill in "Ends at" with "2009-11-04 23:59:59"
    And I fill in "Results available at" with "2009-11-05 12:00:00"
    And I fill in "Contact name" with "Board of Elections"
    And I fill in "Contact email" with "elections@example.com"
    And I fill in "Verify message" with "Thank you for voting."
    And I press "Create"
    Then I should see "Name: 2008 Election"
    And I should see "Starts at: 2008-11-04 00:00:01"
    And I should see "Ends at: 2009-11-04 23:59:59"
    And I should see "Results available at: 2009-11-05 12:00:00"
    And I should see "Contact name: Board of Elections"
    And I should see "Contact email: elections@example.com"
    And I should see "Thank you for voting."

  Scenario: Delete election
    Given I logged in as the administrator
    And the following elections exist
      |name  |
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd election
    Then I should see the following elections:
      |Name  |
      |name 1|
      |name 2|
      |name 4|

