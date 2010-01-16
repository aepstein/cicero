Feature: Manage elections
  In order to set up, monitor, and manage elections
  As an administrator
  I want to create, edit, list, and delete elections

  Scenario Outline: Test permissions for candidates controller actions
    Given an election: "basic" exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I logged in as "<user>" with password "secret"
    And I am on the new election page
    Then I should <create>
    Given I post on the elections page
    Then I should <create>
    And I am on the edit page for election: "basic"
    Then I should <update>
    Given I put on the page for election: "basic"
    Then I should <update>
    Given I am on the page for election: "basic"
    Then I should <show>
    Given I delete on the page for election: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

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
    Given an election exists with name: "election 4"
    And an election exists with name: "election 3"
    And an election exists with name: "election 2"
    And an election exists with name: "election 1"
    And I logged in as the administrator
    When I delete the 3rd election
    Then I should see the following elections:
      |Name      |
      |election 1|
      |election 2|
      |election 4|

