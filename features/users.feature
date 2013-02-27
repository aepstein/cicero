Feature: Manage users
  In order to represent people in the elections
  As a secure process
  I want to create, list, edit, and delete users

  Scenario Outline: Access control
    Given a user exists to whom I have a <relation> relationship
    Then I <show> see the user
    And I <create> create users
    And I <update> update the user
    And I <destroy> destroy the user
    Examples:
      |relation|show   |create |update |destroy|
      |admin   |may    |may    |may    |may    |
      |plain   |may not|may not|may not|may not|

  Scenario Outline: Create/edit a user
    Given I log in as the <role> user
    When I create a user as <role>
    Then I should see the new user as <role>
    When I update the user as <role>
    Then I should see the edited user as <role>
    Examples:
      |role |
      |admin|

  Scenario: Search users
    Given I log in as the admin user
    And there are 4 users
    # contains first name
    When I search for users with name "35"
    Then I should see the following users:
      | User 13, Sequenced35 |
    # contains last name
    When I search for users with name "13"
    Then I should see the following users:
      | User 13, Sequenced35 |
    # contains netid
    When I search for users with name "24"
    Then I should see the following users:
      | User 13, Sequenced35 |

  Scenario: List/delete a user
    Given I log in as the admin user
    And there are 4 users
    And I "Destroy" the 4th user
    Then I should see the following users:
      | Administrator, Senior |
      | User 11, Sequenced33  |
      | User 12, Sequenced34  |
      | User 14, Sequenced36  |

  Scenario Outline: Populate users into rolls in bulk
    Given I log in as the admin user
    And a roll exists
    When I set users for the roll via <method>
    Then I should see users enrolled
    Examples:
      |method    |
      |text      |
      |attachment|

