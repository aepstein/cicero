Feature: Manage petitioners
  In order to track users who sign petitions
  As a verifier of petitions
  I want to register, delete, and verify petitioners

  Scenario Outline: Authorization control
    Given a <tense> election exists
    And a candidate exists for the election
    And a petitioner exists for the candidate
    And I have a <relation> relationship to the petitioner
    Then I <see> see the petitioner
    And I <destroy> destroy the petitioner
    And I <create> create a petitioner for the candidate
    Examples:
      | tense  | relation   | see     | destroy | create  |
      | future | admin      | may     | may     | may     |
      | future | petitioner | may     | may not | may not |
      | future | plain      | may not | may not | may not |

  Scenario: Add a petitioner
    Given a future election exists
    And a candidate exists for the election
    And I log in as the admin user
    When I create a petitioner
    Then I should see the new petitioner

  Scenario: Search petitioners
    Given a future election exists
    And a candidate exists for the election
    And there are 4 petitioners for the candidate
    And I log in as the admin user
    # contains first name
    When I search for petitioners for the candidate with name "35"
    Then I should see the following petitioners:
      | Sequenced35 User 13 |
    # contains last name
    When I search for petitioners for the candidate with name "13"
    Then I should see the following petitioners:
      | Sequenced35 User 13 |
    # contains netid
    When I search for petitioners for the candidate with name "24"
    Then I should see the following petitioners:
      | Sequenced35 User 13 |

  Scenario: List/delete a petitioners
    Given a current election exists
    And a candidate exists for the election
    And there are 4 petitioners for the candidate
    And I log in as the admin user
    And I "Destroy" the 3rd petitioner for the candidate
    Then I should see the following petitioners:
      | Sequenced33 User 11 |
      | Sequenced34 User 12 |
      | Sequenced36 User 14 |

