Feature: Manage ballots
  In order to cast votes
  As a an eligible voter
  I want to prepare, confirm, and create ballots

  Scenario Outline: Test permissions for candidates controller actions
    Given an election exists
    And the election is a current election
    And a roll exists with election: the election
    And a user: "voter" exists with net_id: "voter", password: "secret", admin: false
    And the user is amongst the users of the roll
    And a ballot exists with election: the election, user: the user
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I logged in as "<user>" with password "secret"
    Given I am on the page for the ballot
    Then I should <show>
    Given I delete on the page for the ballot
    Then I should <destroy>
    Given there are no ballots
    And I am on the new ballot page for the election
    Then I should <create>
    Given I post on the ballots page for the election
    Then I should <create>
    Given I am on the preview ballot page for the election
    Then I should <preview>
    Examples:
      | user    | create                 | destroy                | show                   | preview                |
      | admin   | see "Unauthorized"     | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | voter   | not see "Unauthorized" | see "Unauthorized"     | not see "Unauthorized" | see "Unauthorized"     |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

  Scenario: Cast new ballot (unranked)
    Given a user: "voter" exists with net_id: "voter", password: "secret"
    And an election: "2008" exists with name: "2008 General"
    And a roll: "national" exists with name: "United States Citizens", election: election "2008"
    And the user is in the users of the roll
    And a race: "potus" exists with name: "President of the United States", roll: roll "national", election: election "2008", is_ranked: false
    And a candidate: "obama" exists with name: "Barack Obama", race: race "potus"
    And a candidate: "mccain" exists with name: "John McCain", race: race "potus"
    And a race: "vpotus" exists with name: "Vice President of the United States", roll: roll "national", election: election "2008", is_ranked: false
    And a candidate: "biden" exists with name: "Joseph Biden", race: race "vpotus"
    And a candidate: "palin" exists with name: "Sarah Palin", race: race "vpotus"
    And the election is a current election
    And I logged in as "voter" with password "secret"
    And I check "Barack Obama"
    And I check "Joseph Biden"
    And I press "Continue"
    And I choose "ballot_confirmation_true"
    And I press "Continue"
    Then I should see "Ballot was successfully created."

  Scenario: Cast new ballot (ranked)
    Given a user: "voter" exists with net_id: "voter", password: "secret"
    And an election: "2008" exists with name: "2008 General"
    And a roll: "national" exists with name: "United States Citizens", election: election "2008"
    And the user is in the users of the roll
    And a race: "potus" exists with name: "President of the United States", roll: roll "national", election: election "2008", is_ranked: true
    And a candidate: "obama" exists with name: "Barack Obama", race: race "potus"
    And a candidate: "mccain" exists with name: "John McCain", race: race "potus"
    And a race: "vpotus" exists with name: "Vice President of the United States", roll: roll "national", election: election "2008", is_ranked: true
    And a candidate: "biden" exists with name: "Joseph Biden", race: race "vpotus"
    And a candidate: "palin" exists with name: "Sarah Palin", race: race "vpotus"
    And the election is a current election
    And I logged in as "voter" with password "secret"
    And I select "1" from "Barack Obama"
    And I select "2" from "John McCain"
    And I select "1" from "Joseph Biden"
    And I press "Continue"
    Then I should see "Warning: 1 fewer votes are selected than the 2 that are allowed for the race Vice President of the United States"
    And I choose "ballot_confirmation_true"
    And I press "Continue"
    Then I should see "Ballot was successfully created."

