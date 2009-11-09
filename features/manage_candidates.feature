Feature: Manage candidates
  In order to represent candidates for vote
  As a an election manager
  I want to add, modify, remove, and list candidates

  Background:
    Given an election: "2008" exists with name: "2008 General"
    And a roll: "national" exists with name: "All US Citizens", election: election "2008"
    And a race: "potus" exists with name: "President of the United States", election: election "2008", roll: roll "national"

  Scenario: Register new candidate
    Given a candidate: "dem" exists with name: "Barack Obama", race: race "potus"
    And a race: "vpotus" exists with name: "Vice President of the United States", election: election "2008", roll: roll "national"
    And I logged in as the administrator
    And I am on the new candidate page for race "vpotus"
    When I fill in "Name" with "Joseph Biden"
    And I fill in "Statement" with "Yes we can!"
    And I choose "candidate_disqualified_false"
    And I select "Barack Obama" from "Linked candidate"
    And I attach the file at "" to "Picture"
    And I fill in "Picture" with "spec/assets/robin.jpg"
    And I press "Create"
    Then I should see "Candidate was successfully created."
    And I should see "Name: Joseph Biden"
    And I should see "Yes we can!"
    And I should see "Disqualified? No"
    And I should see "Linked candidate: Barack Obama"
    And I should see "Picture: Yes"

  Scenario: Delete candidate
    Given a candidate exists with name: "candidate 4", race: race "potus"
    And a candidate exists with name: "candidate 3", race: race "potus"
    And a candidate exists with name: "candidate 2", race: race "potus"
    And a candidate exists with name: "candidate 1", race: race "potus"
    And I logged in as the administrator
    When I delete the 3rd candidate for race "potus"
    Then I should see the following candidates:
      |Name       |
      |candidate 1|
      |candidate 2|
      |candidate 4|

