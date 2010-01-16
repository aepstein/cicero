Feature: Manage users
  In order to represent people in the elections
  As a secure process
  I want to create, list, edit, and delete users

  Scenario Outline: Test permissions for candidates controller actions
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a user exists with net_id: "owner", password: "secret", admin: false
    And I logged in as "<user>" with password "secret"
    And I am on the new user page
    Then I should <create>
    Given I post on the users page
    Then I should <create>
    And I am on the edit page for the user
    Then I should <update>
    Given I put on the page for the user
    Then I should <update>
    Given I am on the page for the user
    Then I should <show>
    Given I delete on the page for the user
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | owner   | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

  Scenario: Register new user
    Given I logged in as the administrator
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
    And I logged in as the administrator
    When I delete the 3rd user
    Then I should see the following users:
      |Net id  |First name  |Last name  |
      |net1    |John        |Doe 1      |
      |net2    |John        |Doe 2      |
      |net4    |John        |Doe 4      |
      |admin   |First       |Last       |

