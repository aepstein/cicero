Feature: Manage petitioners
  In order to track users who sign petitions
  As a verifier of petitions
  I want to register, delete, and verify petitioners

  Background:
    Given an election: "2008" exists with name: "2008 General"
    And a roll: "national" exists with name: "United States Citizens", election: election "2008"
    And a race: "potus" exists with name: "President of the United States", roll: roll "national", election: election "2008", is_ranked: false
    And a candidate: "obama" exists with race: race "potus"

  Scenario: Register new petitioner
    Given a user: "voter" exists with net_id: "vot123", password: "secret", first_name: "John", last_name: "Doe"
    And the user is in the users of the roll
    And a candidate: "obama" exists with name: "Barack Obama", race: race "potus"
    And a candidate: "mccain" exists with name: "John McCain", race: race "potus"
    And I logged in as the administrator
    And I am on the new petitioner page for candidate "obama"
    When I fill in "petitioner[net_id]" with "vot123"
    And I press "Create"
    Then I should see "Petitioner was successfully created."
    And I should see the following petitioners:
      |User     |
      |John Doe |

  Scenario: Delete petitioner
    Given a user: "voter4" exists with last_name: "Gamma", first_name: "Michael"
    And the user is in the users of the roll
    And a petitioner exists with user: user "voter4", candidate: candidate "obama"
    And a user: "voter3" exists with last_name: "Delta", first_name: "Bill"
    And the user is in the users of the roll
    And a petitioner exists with user: user "voter3", candidate: candidate "obama"
    And a user: "voter2" exists with last_name: "Beta", first_name: "Uri"
    And the user is in the users of the roll
    And a petitioner exists with user: user "voter2", candidate: candidate "obama"
    And a user: "voter1" exists with last_name: "Alpha", first_name: "Joe"
    And the user is in the users of the roll
    And a petitioner exists with user: user "voter1", candidate: candidate "obama"
    And I logged in as the administrator
    When I delete the 3rd petitioner for candidate "obama"
    Then I should see the following petitioners:
      |User         |
      |Joe Alpha    |
      |Uri Beta     |
      |Michael Gamma|

