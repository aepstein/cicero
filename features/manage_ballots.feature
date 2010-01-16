Feature: Manage ballots
  In order to cast votes
  As a an eligible voter
  I want to prepare, confirm, and create ballots

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

