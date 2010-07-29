Feature: Manage users
  In order to represent people in the elections
  As a secure process
  I want to create, list, edit, and delete users

  Background:
    Given a user: "admin" exists with admin: true, net_id: "admin", first_name: "First", last_name: "Last"

  Scenario Outline: Test permissions for candidates controller actions
    Given a user: "owner" exists with last_name: "Vital"
    And a user: "regular" exists
    And I log in as user: "<user>"
    Given I am on the page for the user
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the users page
    Then I should <show> "Vital"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New user"
    Given I am on the new user page
    Then I should <create> authorized
    Given I post on the users page
    Then I should <create> authorized
    And I am on the edit page for the user
    Then I should <update> authorized
    Given I put on the page for the user
    Then I should <update> authorized
    Given I delete on the page for the user
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | owner   | not see | not see | not see | see     |
      | regular | not see | not see | not see | not see |

  Scenario: Register new user
    Given I log in as user: "admin"
    And I am on the new user page
    When I fill in "Net" with "jd1"
    And I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I choose "user_admin_false"
    And I fill in "Email" with "jd1@example.com"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Create"
    Then I should see "User was successfully created."
    And I should see "Net id: jd1"
    And I should see "First name: John"
    And I should see "Last name: Doe"
    And I should see "Admin? No"
    And I should see "Email: jd1@example.com"

  Scenario: Delete user
    Given a user exists with net_id: "net4", first_name: "John", last_name: "Doe 4"
    And a user exists with net_id: "net3", first_name: "John", last_name: "Doe 3"
    And a user exists with net_id: "net2", first_name: "John", last_name: "Doe 2"
    And a user exists with net_id: "net1", first_name: "John", last_name: "Doe 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd user
    Then I should see the following users:
      |Net id  |First name  |Last name  |
      |net1    |John        |Doe 1      |
      |net2    |John        |Doe 2      |
      |net4    |John        |Doe 4      |
      |admin   |First       |Last       |

  Scenario: Add users to roll in bulk (from csv text)
    Given a roll exists
    And I log in as user: "admin"
    And I am on the page for the roll
    And I follow "Import users"
    And I fill in "users" with "jd1,jd1@example.com,John,Doe"
    And I press "Add users to roll"
    Then I should see "Processed new voters: 1 new voters and 1 new users."
    Given I am on the users page for the roll
    Then I should see the following users:
      | Net id | First name | Last name |
      | jd1    | John       | Doe       |

  Scenario: Add users to roll in bulk (from csv file)
    Given a roll exists
    And I log in as user: "admin"
    And I am on the page for the roll
    And I follow "Import users"
    And I attach the file "spec/assets/users.csv" to "users_file"
    And I press "Add users to roll"
    Then I should see "Processed new voters: 2 new voters and 2 new users."
    Given I am on the users page for the roll
    Then I should see the following users:
      | Net id | First name | Last name |
      | jd2    | Jane       | Doe       |
      | jd1    | John       | Doe       |

