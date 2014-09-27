Feature: Manage elections
  In order to set up, monitor, and manage elections
  As an administrator
  I want to create, edit, list, and delete elections

  Scenario Outline: Test permissions for elections controller actions
    Given a <tense> <type> election exists
    And I log in as the <role> user
    And I <vote> vote in the election
    Then I <see> see the election
    And I <tabulate> tabulate the election
    And I <update> update the election
    And I <create> create elections
    And I <destroy> destroy the election
    Examples:
      |tense  |type   |role |vote   |create |update |destroy|see    |tabulate|
      |current|public |admin|may not|may    |may    |may    |may    |may not |
      |current|public |plain|may not|may not|may not|may not|may    |may not |
      |past   |public |admin|may not|may    |may    |may    |may    |may     |
      |past   |public |plain|may not|may not|may not|may not|may    |may not |
      |future |public |admin|may not|may    |may    |may    |may    |may not |
      |future |public |plain|may not|may not|may not|may not|may not|may not |
      |current|private|admin|may not|may    |may    |may    |may    |may not |
      |current|private|plain|may not|may not|may not|may not|may not|may not |
      |current|private|plain|may    |may not|may not|may not|may    |may not |
      |past   |private|admin|may not|may    |may    |may    |may    |may     |
      |past   |private|plain|may not|may not|may not|may not|may not|may not |
      |past   |private|plain|may    |may not|may not|may not|may    |may not |
      |future |private|admin|may not|may    |may    |may    |may    |may not |
      |future |private|plain|may not|may not|may not|may not|may not|may not |

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

