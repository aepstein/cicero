Feature: Manage user_sessions
  In order to assure users are whom they claim to be
  As a secure service
  I want to log in and log out users

  Background:
    Given a user: "admin" exists with admin: true

  Scenario: Register new user_session (log in)
    Given I log in as user: "admin"
    Then I should see "You logged in successfully."

  Scenario: Delete user_session (log out)
    Given I log in as user: "admin"
    When I log out
    Then I should see "You logged out successfully."

