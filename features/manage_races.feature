Feature: Manage races
  In order to conduct election
  As an election manager
  I want to create, show, destroy, and update races

  Scenario Outline: Test permissions for candidates controller actions
    Given an election exists
    And a race exists with election: the election
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I logged in as "<user>" with password "secret"
    And I am on the new race page for the election
    Then I should <create>
    Given I post on the races page for the election
    Then I should <create>
    And I am on the edit page for the race
    Then I should <update>
    Given I put on the page for the race
    Then I should <update>
    Given I am on the page for the race
    Then I should <show>
    Given I delete on the page for the race
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

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
@wip
  Scenario: Display ballots cast for race
    Given an election: "2008" exists with name: "2008 General Election"
    And a roll exists with election: the election
    And a user exists
    And the user is amongst the users of the roll
    And a race: "first" exists with name: "Popular, Race", roll: the roll, slots: 1, election: the election
    And a race exists with election: the election, roll: the roll
    And a candidate: "bottom" exists with name: "Bottom", race: race "first"
    And a candidate: "middle" exists with name: "Middle", disqualified: true, race: race "first"
    And a candidate: "top" exists with name: "Top", race: race "first"
    And a ballot exists with election: the election, user: the user
    And a section exists with ballot: the ballot, race: race "first"
    And a vote exists with section: the section, candidate: candidate "top", rank: 1
    And a vote exists with section: the section, candidate: candidate "middle", rank: 2
    And a vote exists with section: the section, candidate: candidate "bottom", rank: 3
    And I logged in as the administrator
    And I am on the "blt" ballots page for race: "first"
    Then I should see
      """
3 1
-2
1 3 2 1 0
0
\"Bottom\"
\"Middle\"
\"Top\"
\"Popular, Race\"
      """

