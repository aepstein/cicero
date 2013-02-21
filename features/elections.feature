Feature: Manage elections
  In order to set up, monitor, and manage elections
  As an administrator
  I want to create, edit, list, and delete elections

  Scenario Outline: Test permissions for elections controller actions
    Given a <tense> election exists
    And I log in as the <role> user
    Then I <see> see the election
    And I <update> update the election
    And I <create> create elections
    And I <destroy> destroy the election
    Examples:
      |tense  |role |create |update |destroy|see    |
      |current|admin|may    |may    |may    |may    |
      |current|plain|may not|may not|may not|may    |
      |past   |admin|may    |may    |may    |may    |
      |past   |plain|may not|may not|may not|may    |
      |future |admin|may    |may    |may    |may    |
      |future |plain|may not|may not|may not|may not|

  @javascript
  Scenario: Create and edit election
    Given I log in as the admin user
    When I create an election
    Then I should see the new election
    When I update the election
    Then I should see the edited election

  Scenario: List/delete a election
    Given I log in as the admin user
    And there are 4 elections
    And I "Destroy" the 3rd election
    Then I should see the following elections:
    | election 1 |
    | election 2 |
    | election 4 |

