Feature: Manage rolls
  In order to track and enforce who is allowed to vote and sign petitions
  As a security-minded organization
  I want to create, maintain, show, list, and populate rolls

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for candidates controller actions
    Given a <when>election exists
    And a roll exists with election: the election, name: "Vital"
    And I log in as user: "<user>"
    Given am on the page for the roll
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the rolls page for the election
    Then I should <show> "Vital"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New roll"
    Given I am on the new roll page for the election
    Then I should <create> authorized
    Given I post on the rolls page for the election
    Then I should <create> authorized
    And I am on the edit page for the roll
    Then I should <update> authorized
    Given I put on the page for the roll
    Then I should <update> authorized
    Given I delete on the page for the roll
    Then I should <destroy> authorized
    Examples:
      | when    | user    | create  | update  | destroy | show    |
      |         | admin   | see     | see     | see     | see     |
      |         | regular | not see | not see | not see | see     |
      | past_   | admin   | see     | see     | see     | see     |
      | past_   | regular | not see | not see | not see | see     |
      | future_ | admin   | see     | see     | see     | see     |
      | future_ | regular | not see | not see | not see | not see |

  Scenario: Register new roll
    Given an election exists with name: "2008 General"
    And I log in as user: "admin"
    And I am on the new roll page for the election
    When I fill in "Name" with "All US Citizens"
    And I press "Create"
    Then I should see "Roll was successfully created."
    And I should see "Election: 2008 General"
    And I should see "Name: All US Citizens"

  Scenario: Delete roll
    Given an election: "2008" exists with name: "2008 General"
    And a roll exists with name: "roll 4", election: election "2008"
    And a roll exists with name: "roll 3", election: election "2008"
    And a roll exists with name: "roll 2", election: election "2008"
    And a roll exists with name: "roll 1", election: election "2008"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd roll for the election
    Then I should see the following rolls:
      | Name   |
      | roll 1 |
      | roll 2 |
      | roll 4 |

