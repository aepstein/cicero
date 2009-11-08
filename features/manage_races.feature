Feature: Manage races
  In order to conduct election
  As an election manager
  I want to create, show, destroy, and update races

  Scenario: Register new race
    Given I logged in as the administrator
    And an election: "2008" exists with name: "2008 General Election"
    And a roll: "national" exists with name: "All US Citizens", election: the election
    And I am on the new race page for the election
    When I fill in "Name" with "President of the United States"
    And I fill in "Slots" with "1"
    And I choose "race_is_ranked_true"
    And I select "All US Citizens" from "Roll"
    And I fill in "Description" with "This is the most important race on the ballot."
    And I press "Create"
    Then I should see "Name: President of the United States"
    And I should see "Slots: 1"
    And I should see "Is ranked? Yes"
    And I should see "Roll: All US Citizens"
    And I should see "This is the most important race on the ballot."
  @wip
  Scenario: Delete race
    Given the following races exist
      |name  |slots|is_ranked|roll  |
      |name 1|1    |false    |roll 1|
      |name 2|1    |true     |roll 2|
      |name 3|1    |false    |roll 3|
      |name 4|1    |true     |roll 4|
    When I delete the 3rd race
    Then I should see the following races:
      |Name  |Slots|Is ranked|Roll  |
      |name 1|1    |false    |roll 1|
      |name 2|1    |true     |roll 2|
      |name 4|1    |true     |roll 4|

