Feature: Manage rolls
  In order to track and enforce who is allowed to vote and sign petitions
  As a security-minded organization
  I want to create, maintain, show, list, and populate rolls

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

