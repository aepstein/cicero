Feature: Manage elections
  In order to set up, monitor, and manage elections
  As an administrator
  I want to create, edit, list, and delete elections

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists
@wip
  Scenario Outline: Test permissions for candidates controller actions
    Given a <when>election: "basic" exists with name: "Vital"
    And I log in as user: "<user>"
    And I am on the new election page
    Then I should <create> authorized
    Given I post on the elections page
    Then I should <create> authorized
    And I am on the edit page for election: "basic"
    Then I should <update> authorized
    Given I put on the page for election: "basic"
    Then I should <update> authorized
    Given I am on the page for election: "basic"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the elections page
    Then I should <show> "Vital"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New election"
    Given I delete on the page for election: "basic"
    Then I should <destroy> authorized
    Examples:
      | when    | user    | create  | update  | destroy | show     |
      |         | admin   | see     | see     | see     | see      |
      |         | regular | not see | not see | not see | see      |
      | past_   | admin   | see     | see     | see     | see      |
      | past_   | regular | not see | not see | not see | see      |
      | future_ | admin   | see     | see     | see     | see      |
      | future_ | regular | not see | not see | not see | not see  |

  Scenario: Register new election
    Given I log in as user: "admin"
    And I am on the new election page
    When I fill in "Name" with "2008 Election"
    And I fill in "Starts at" with "2008-11-04 00:00:01"
    And I fill in "Ends at" with "2008-11-04 23:59:59"
    And I fill in "Results available at" with "2008-11-05 12:00:00"
    And I fill in "Contact name" with "Board of Elections"
    And I fill in "Contact email" with "elections@example.com"
    And I fill in "Verify message" with "Thank you for *voting*."
    And I press "Create"
    Then I should see "Name: 2008 Election"
    And I should see "Starts at: November 4th, 2008 12:00am"
    And I should see "Ends at: November 4th, 2008 11:59pm"
    And I should see "Results available at: November 5th, 2008 12:00pm"
    And I should see "Contact name: Board of Elections"
    And I should see "Contact email: elections@example.com"
    And I should see "Thank you for voting."

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

