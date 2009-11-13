Feature: Manage users
  In order to represent people in the elections
  As a secure process
  I want to create, list, edit, and delete users

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
    Given the following users exist
      |net_id  |first_name  |last_name  |
      |net4    |first_name 4|last_name 4|
      |net3    |first_name 3|last_name 3|
      |net2    |first_name 2|last_name 2|
      |net1    |first_name 1|last_name 1|
    And I logged in as the administrator
    When I delete the 3rd user
    Then I should see the following users:
      |Net id  |First name  |Last name  |
      |admin   |First       |Last       |
      |net1    |first_name 1|last_name 1|
      |net2    |first_name 2|last_name 2|
      |net4    |first_name 4|last_name 4|

