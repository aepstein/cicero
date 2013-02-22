Feature: Manage ballots
  In order to cast votes
  As a an eligible voter
  I want to prepare, confirm, and create ballots

  Scenario Outline: Permission to cast a ballot
    Given a <tense> election exists
    And I have a <relationship> relationship to the election
    And I <cast> cast a ballot for the election
    Then I <create> cast a ballot for the election
    Examples:
      | tense   | relationship | cast     | create  |
      | current | admin        | have not | may not |
      | past    | voter        | have not | may not |
      | current | voter        | have not | may     |
      | current | plain        | have not | may not |
      | current | voter        | have     | may not |
      | future  | voter        | have not | may not |

  Scenario Outline: Permission to manipulate existing ballots
    Given a <tense> election exists
    And a race exists for the election
    And a ballot is cast for the race to which I have a <relation> relationship
    Then I <see> see the ballot
    And I <tabulate> tabulate the ballot
    And I <destroy> destroy the ballot
    Examples:
      | tense   | relation | see     | tabulate | destroy |
      | past    | admin    | may     | may      | may     |
      | current | voter    | may     | may not  | may not |
      | current | enrolled | may not | may not  | may not |
      | current | plain    | may not | may not  | may not |

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
    And I log in as user: "voter"
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
    And I log in as user: "voter"
    And I select "1" from "Barack Obama"
    And I select "2" from "John McCain"
    And I select "1" from "Joseph Biden"
    And I press "Continue"
    Then I should see "1 fewer votes are selected than the 2 that are allowed for the race Vice President of the United States"
    And I choose "ballot_confirmation_true"
    And I press "Continue"
    Then I should see "Ballot was successfully created."

