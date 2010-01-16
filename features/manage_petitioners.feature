@wip
Feature: Manage petitioners
  In order to track users who sign petitions
  As a verifier of petitions
  I want to register, delete, and verify petitioners

  Background:
    Given an election: "2008" exists with name: "2008 General"
    And a roll: "national" exists with name: "United States Citizens", election: election "2008"
    And a race: "potus" exists with name: "President of the United States", roll: roll "national", election: election "2008", is_ranked: false
    And a candidate: "obama" exists with race: race "potus"

  Scenario Outline: Test permissions for candidates controller actions
    Given an election exists
    And a roll exists with election: the election
    And a user: "voter" exists
    And the user is amongst the users of the roll
    And a race exists with roll: the roll, election: the election
    And a candidate: "basic" exists with race: the race
    And a petitioner: "basic" exists with candidate: candidate "basic", user: user "voter"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I logged in as "<user>" with password "secret"
    And I am on the new petitioner page for candidate: "basic"
    Then I should <create>
    Given I post on the petitioners page for candidate: "basic"
    Then I should <create>
    And I am on the edit page for petitioner: "basic"
    Then I should <update>
    Given I put on the page for petitioner: "basic"
    Then I should <update>
    Given I am on the page for petitioner: "basic"
    Then I should <show>
    Given I delete on the page for petitioner: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new petitioner
    Given a user: "voter" exists with net_id: "vot123", password: "secret", first_name: "John", last_name: "Doe"
    And the user is in the users of the roll
    And I logged in as the administrator
    And I am on the new petitioner page for candidate: "obama"
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

