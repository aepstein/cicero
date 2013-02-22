Given /^a race exists for the election$/ do
  @race = create( :race, election: @election )
end

