Given /^I am enrolled in (\d+) current elections$/ do |quantity|
  quantity = quantity.to_i
  @elections = if quantity > 0
    (1..quantity).map do |i|
      election = create(:current_election, name: "Election #{i}")
      create(:roll, election: election ).users << @current_user
      election
    end
  else
    []
  end
end

Given /^I voted in (\d+) of those elections$/ do |quantity|
  quantity = quantity.to_i
  quantity.times do |i|
    create(:ballot, election: @elections[i], user: @current_user)
  end
end

Then /^I should see the home page with (\d+) enrolled, (\d+) cast elections?$/ do |enrolled, cast|
  no_remaining_message = "There are no elections remaining for you to vote in at this time."
  remaining_message = "Please select the election in which you wish to vote:"
  enrolled = enrolled.to_i
  cast = cast.to_i
  if enrolled > cast
    page.should have_text remaining_message
    page.should have_no_text no_remaining_message
    within("#active-elections") do
      @elections[cast..enrolled].each do |election|
        page.should have_selector "#election-#{election.id}"
      end
    end
  else
    page.should have_no_text remaining_message
    page.should have_text no_remaining_message
  end
  cast_message = "You previously voted in these elections:"
  if cast > 0
    page.should have_text cast_message
    within("#cast-ballots") do
      @elections[0..cast].each do |election|
        page.should have_text election.name
      end
    end
  else
    page.should have_no_text cast_message
  end
end

Then /^I should see the ballot for the (\d+)(?:st|nd|rd|th)? election$/ do |i|
  i = i.to_i - 1
  current_path.should eql new_election_ballot_path( @elections[i] )
end

