Feature: Manage candidates
  In order to represent candidates for vote
  As a an election manager
  I want to add, modify, remove, and list candidates

  Background:
    Given an election: "2008" exists with name: "2008 General"
    And a roll: "national" exists with name: "All US Citizens", election: election "2008"
    And a race: "potus" exists with name: "President of the United States", election: election "2008", roll: roll "national"
    And a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for candidates controller actions
    Given a <when>election exists
    And race exists with election: the election
    And a candidate exists with race: the race, name: "Vital"
    And I log in as user: "<user>"
    And I am on the page for the candidate
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the candidates page for the race
    Then I should <show> "Vital"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New candidate"
    Given I am on the new candidate page for the race
    Then I should <create> authorized
    Given I post on the candidates page for the race
    Then I should <create> authorized
    And I am on the edit page for the candidate
    Then I should <update> authorized
    Given I put on the page for the candidate
    Then I should <update> authorized
    Given I delete on the page for the candidate
    Then I should <destroy> authorized
    Examples:
      | when    | user    | create  | update  | destroy | show    |
      |         | admin   | see     | see     | see     | see     |
      |         | regular | not see | not see | not see | see     |
      | past_   | admin   | see     | see     | see     | see     |
      | past_   | regular | not see | not see | not see | see     |
      | future_ | admin   | see     | see     | see     | see     |
      | future_ | regular | not see | not see | not see | not see |

  Scenario: Register new candidate
    Given a candidate: "dem" exists with name: "Barack Obama", race: race "potus"
    And a race: "vpotus" exists with name: "Vice President of the United States", election: election "2008", roll: roll "national"
    And I log in as user: "admin"
    And I am on the new candidate page for race: "vpotus"
    When I fill in "Name" with "Joseph Biden"
    And I fill in "Statement" with "Yes we can!"
    And I choose "No"
    And I attach the file "spec/assets/robin.jpg" to "Picture"
    And I press "Create"
    Then I should see "Candidate was successfully created."
    And I should see "Name: Joseph Biden"
    And I should see "Yes we can!"
    And I should see "Disqualified? No"
    And I should see "Picture: Yes"

  Scenario: Delete candidate
    Given a candidate exists with name: "candidate 4", race: race "potus"
    And a candidate exists with name: "candidate 3", race: race "potus"
    And a candidate exists with name: "candidate 2", race: race "potus"
    And a candidate exists with name: "candidate 1", race: race "potus"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd candidate for race "potus"
    Then I should see the following candidates:
      |Name       |
      |candidate 1|
      |candidate 2|
      |candidate 4|

