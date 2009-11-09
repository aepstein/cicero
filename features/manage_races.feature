Feature: Manage races
  In order to conduct election
  As an election manager
  I want to create, show, destroy, and update races

  Scenario: Register new race
    Given I logged in as the administrator
    And an election: "2008" exists with name: "2008 General Election"
    And a roll: "national" exists with name: "All US Citizens", election: the election
    And I am on the new race page for the election
    When I fill in "Name" with "President of the United States"
    And I fill in "Slots" with "1"
    And I choose "race_is_ranked_true"
    And I select "All US Citizens" from "Roll"
    And I fill in "Description" with "This is the most important race on the ballot."
    And I press "Create"
    Then I should see "Name: President of the United States"
    And I should see "Slots: 1"
    And I should see "Is ranked? Yes"
    And I should see "Roll: All US Citizens"
    And I should see "This is the most important race on the ballot."

  Scenario: Delete race
    Given an election: "2008" exists with name: "2008 General Election"
    And a roll: "national" exists with name: "All US Citizens", election: election "2008"
    And a race exists with name: "First", slots: 1, is_ranked: false, roll: roll "national", election: election "2008"
    And a race exists with name: "Second", slots: 1, is_ranked: false, roll: roll "national", election: election "2008"
    And a race exists with name: "Third", slots: 1, is_ranked: false, roll: roll "national", election: election "2008"
    And a race exists with name: "Fourth", slots: 1, is_ranked: false, roll: roll "national", election: election "2008"
    And I logged in as the administrator
    When I delete the 3rd race for election "2008"
    Then I should see the following races:
      |Name   |Slots|Ranked? |Roll           |
      |First  |1    |No      |All US Citizens|
      |Fourth |1    |No      |All US Citizens|
      |Third  |1    |No      |All US Citizens|

