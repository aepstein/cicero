@wip
Feature: Manage candidates
  In order to represent candidates for vote
  As a an election manager
  I want to add, modify, remove, and list candidates

  Scenario: Register new candidate
    Given I am on the new candidate page
    When I fill in "Name" with "Barack Obama"
    And I fill in "Statement" with "Yes we can!"
    And I choose "candidate_disqualified_false"
    And I select "Joseph Biden" from "Linked candidate"
    And I attach the file at "" to "Picture"
    And I fill in "Picture" with "picture 1"
    And I press "Create"
    Then I should see "name 1"
    And I should see "statement 1"
    And I should see "false"
    And I should see "linked_candidate 1"
    And I should see "picture 1"

  Scenario: Delete candidate
    Given the following candidates:
      |name|statement|disqualified|linked_candidate|picture|
      |name 1|statement 1|false|linked_candidate 1|picture 1|
      |name 2|statement 2|true|linked_candidate 2|picture 2|
      |name 3|statement 3|false|linked_candidate 3|picture 3|
      |name 4|statement 4|true|linked_candidate 4|picture 4|
    When I delete the 3rd candidate
    Then I should see the following candidates:
      |Name|Statement|Disqualified|Linked candidate|Picture|
      |name 1|statement 1|false|linked_candidate 1|picture 1|
      |name 2|statement 2|true|linked_candidate 2|picture 2|
      |name 4|statement 4|true|linked_candidate 4|picture 4|

