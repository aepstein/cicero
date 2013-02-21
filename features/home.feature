Feature: Home page
  In order to find my ballot and know what elections I voted in
  As a lay user
  I want a foolproof home page
@wip
  Scenario Outline:
    Given I am the plain user
    And I am enrolled in <enrolled> current elections
    And I have cast ballots in <cast> of those elections
    When I log in
    Then I should see <see>
    Examples:
      | enrolled | cast | see                                            |
      | 1        | 0    | the ballot for the 1st election                |
      | 1        | 1    | the home page with 0 enrolled, 1 cast election |
      | 2        | 1    | the ballot for the 2nd election                |
      | 2        | 0    | the home page with 2 enrolled, 0 cast elections|
      | 0        | 0    | the home page with 0 enrolled, 0 cast elections|

