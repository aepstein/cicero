Feature: Manage petitioners
  In order to track users who sign petitions
  As a verifier of petitions
  I want to register, delete, and verify petitioners

  Background:
    Given an election: "2008" exists with name: "2008 General"
    And a roll: "national" exists with name: "United States Citizens", election: election "2008"
    And a race: "potus" exists with name: "President of the United States", roll: roll "national", election: election "2008", is_ranked: false
    And a candidate: "obama" exists with race: race "potus"
    And a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for candidates controller actions
    Given a <when>election exists
    And a roll exists with election: the election
    And a user: "voter" exists with last_name: "Vital"
    And the user is amongst the users of the roll
    And a race exists with roll: the roll, election: the election
    And a candidate exists with race: the race
    And a petitioner exists with candidate: the candidate, user: user "voter"
    And I log in as user: "<user>"
    Given I am on the page for the petitioner
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the petitioners page for the candidate
    Then I should <show> "Vital"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New petitioner"
    Given I am on the new petitioner page for the candidate
    Then I should <create> authorized
    Given I post on the petitioners page for the candidate
    Then I should <create> authorized
    And I am on the edit page for the petitioner
    Then I should <update> authorized
    Given I put on the page for the petitioner
    Then I should <update> authorized
    Given I delete on the page for the petitioner
    Then I should <destroy> authorized
    Examples:
      | when    | user    | create  | update  | destroy | show    |
      |         | admin   | see     | see     | see     | see     |
      |         | regular | not see | not see | not see | see     |
      | past_   | admin   | see     | see     | see     | see     |
      | past_   | regular | not see | not see | not see | see     |
      | future_ | admin   | see     | see     | see     | see     |
      | future_ | regular | not see | not see | not see | not see |

  Scenario: Register new petitioner
    Given a user: "voter" exists with net_id: "vot123", password: "secret", first_name: "John", last_name: "Doe"
    And the user is in the users of the roll
    And I log in as user: "admin"
    And I am on the new petitioner page for candidate: "obama"
    When I fill in "User" with "vot123"
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
    And I log in as user: "Admin"
    When I follow "Destroy" for the 3rd petitioner for candidate: "obama"
    Then I should see the following petitioners:
      |User         |
      |Joe Alpha    |
      |Uri Beta     |
      |Michael Gamma|

