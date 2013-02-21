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

  Scenario: Delete election
    Given an election exists with name: "election 4"
    And an election exists with name: "election 3"
    And an election exists with name: "election 2"
    And an election exists with name: "election 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd election
    Then I should see the following elections:
      |Name      |
      |election 1|
      |election 2|
      |election 4|

  Scenario Outline: How my elections should behave depending on how a user may vote
    Given an election: "first" exists with name: "First Election"
    And an election: "second" exists with name: "Second Election"
    And a roll: "first" exists with election: election "first"
    And a roll: "second" exists with election: election "second"
    And a user: "first" exists with password: "secret", net_id: "first"
    And a user: "second" exists with password: "secret", net_id: "second"
    And a user: "both" exists with password: "secret", net_id: "both"
    And a user: "neither" exists with password: "secret", net_id: "neither"
    And user: "first" is amongst the users of roll: "first"
    And user: "both" is amongst the users of roll: "first"
    And user: "both" is amongst the users of roll: "second"
    And user: "second" is amongst the users of roll: "second"
    And a ballot exists with user: user "second", election: election "second"
    And I log in as user: "<user>"
    Then I should be on <page>
    And I <first> see "First Election"
    And I <second> see "Second Election"
    And I <none> see "There are no elections remaining for you to vote in at this time."
    Examples:
      | user    | page                                      | first      | second     | none       |
      | first   | the new ballot page for election: "first" | should     | should not | should not |
      | second  | the home page                             | should not | should     | should     |
      | both    | the home page                             | should     | should     | should not |
      | neither | the home page                             | should not | should not | should     |

