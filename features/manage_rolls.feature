Feature: Manage rolls
  In order to track and enforce who is allowed to vote and sign petitions
  As a security-minded organization
  I want to create, maintain, show, list, and populate rolls

  Scenario Outline: Test permissions for candidates controller actions
    Given an election exists
    And a roll exists with election: the election
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I logged in as "<user>" with password "secret"
    And I am on the new roll page for the election
    Then I should <create>
    Given I post on the rolls page for the election
    Then I should <create>
    And I am on the edit page for the roll
    Then I should <update>
    Given I put on the page for the roll
    Then I should <update>
    Given I am on the page for the roll
    Then I should <show>
    Given I delete on the page for the roll
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new roll
    Given an election exists with name: "2008 General"
    And I logged in as the administrator
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
    And I logged in as the administrator
    When I delete the 3rd roll for the election
    Then I should see the following rolls:
      |Name  |
      |roll 1|
      |roll 2|
      |roll 4|

