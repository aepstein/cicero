Given /^a candidate exists for the election$/ do
  @roll = create :roll, election: @election
  @race = create :race, election: @election, roll: @roll
  @candidate = create :candidate, race: @race
end

