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
    And I <list> list the ballots for the election
    And I <tabulate> tabulate the ballot
    And I <destroy> destroy the ballot
    Examples:
      | tense   | relation | see     | list    | tabulate | destroy |
      | past    | admin    | may     | may     | may      | may     |
      | current | voter    | may     | may not | may not  | may not |
      | current | enrolled | may not | may not | may not  | may not |
      | current | plain    | may not | may not | may not  | may not |

  Scenario Outline: See correct instructions
    Given I can vote in a <un>ranked election with <slots> slots
    Then I should see <un>ranked instructions for <slots> slots
    Examples:
      | un | slots |
      |    | 1     |
      | un | 1     |
      | un | 2     |

  Scenario Outline: Cast new ballot (without changing choices)
    Given I can vote in a <un>ranked election
    When I fill in a <in>complete <un>ranked ballot
    Then I should see the confirmation page for the <in>complete <un>ranked ballot
    When I confirm my choices
    Then I should have successfully cast my unchanged <in>complete <un>ranked ballot
    Examples:
      | un | in |
      | un |    |
      |    |    |
      | un | in |
      |    | in |

  Scenario Outline: Cast new ballot (with changing choices)
    Given I can vote in a <un>ranked election
    When I fill in a <in>complete <un>ranked ballot
    Then I should see the confirmation page for the <in>complete <un>ranked ballot
    When I change my choices for the <in>complete <un>ranked ballot
    And I confirm my choices
    Then I should have successfully cast my changed <in>complete <un>ranked ballot
    Examples:
      | un | in |
      | un |    |
      |    |    |
      | un | in |
      |    | in |

  Scenario Outline: Show errors on ballot
    Given I can vote in a <un>ranked election
    When I prepare a ballot that is <error>
    Then I should see an error about the ballot being <error>
    Examples:
      | un | error          |
      | un | overchecked    |
      |    | double-ranked  |
      |    | nonconsecutive |

  @javascript
  Scenario: Modal candidate profiles
    Given I can vote in an unranked election
    When I start a ballot
    And I click on a candidate
    Then the candidate profile should pop up

