Given /^I have( not)? cast a ballot for the election$/ do |negate|
  if negate.blank?
    create(:ballot, election: @election, user: @current_user)
  end
end

Then /^I may( not)? cast a ballot for the election$/ do |negate|
  visit new_election_ballot_url( @election )
  step %{I should#{negate} be authorized}
  Capybara.current_session.driver.submit :post, confirm_new_election_ballot_url( @election ), {}
  step %{I should#{negate} be authorized}
  Capybara.current_session.driver.submit :post, election_ballots_url( @election ), {}
  step %{I should#{negate} be authorized}
end

Given /^a ballot is cast for the race to which I have a (admin|voter|enrolled|plain) relationship$/ do |relation|
  case relation
  when 'admin'
    step %{I log in as the #{relation} user}
  else
    step %{I log in as the plain user}
  end
  case relation
  when 'voter', 'enrolled'
    @race.roll.users << @current_user
  end
  @ballot = if relation == 'voter'
    create :ballot, election: @election, user: @current_user
  else
    create :ballot, election: @election
  end
  @race.roll.users << @ballot.user unless @race.roll.users.include? @ballot.user
  create :section, ballot: @ballot, race: @race
end

Then /^I should( not)? be authorized for the ballot$/ do |negate|
  if negate.present? && page.has_no_selector?(".alert")
    current_path.should eql new_election_ballot_path( @election )
  else
    step %{I should#{negate} be authorized}
  end
end

Then /^I may( not)? see the ballot$/ do |negate|
  visit ballot_url( @ballot )
  step %{I should#{negate} be authorized for the ballot}
  visit user_ballots_url( @ballot.user )
  step %{I should#{negate} be authorized for the ballot}
end

Then /^I may( not)? tabulate the ballot$/ do |negate|
  visit election_ballots_url( @ballot.election )
  step %{I should#{negate} be authorized for the ballot}
  visit race_ballots_url( @race )
  step %{I should#{negate} be authorized for the ballot}
end

Then /^I may( not)? destroy the ballot$/ do |negate|
  visit election_ballots_url( @election )
  if negate.blank?
    within("#ballot-#{@ballot.id}") { page.should have_text "Destroy" }
  end
  Capybara.current_session.driver.submit :delete, ballot_url( @ballot ), {}
  step %{I should#{negate} be authorized for the ballot}
end

