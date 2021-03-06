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

Then /^I should see (un)?ranked instructions for ([0-9]+)? slots$/ do |unranked,slots|
  slots = slots.to_i
  visit new_election_ballot_url( @election )
  if unranked.present?
    if slots == 1
      expect( page ).to have_text "Please mark your choice for this section."
    else
      expect( page ).to have_text "Please mark your choices for this section.  You may choose up to #{slots}."
    end
  else
    expect( page ).to have_text "Please rank all options in your order of preference."
  end
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
  if negate.present?
    step %{I should be alerted that I am unauthorized}
    # TODO verify that we are not on the sought page
  else
    step %{I should be authorized}
  end
end

Then /^I may( not)? see the ballot$/ do |negate|
  visit ballot_url( @ballot )
  step %{I should#{negate} be authorized for the ballot}
  visit user_ballots_url( @ballot.user )
  step %{I should#{negate} be authorized for the ballot}
end

Then /^I may( not)? list the ballots for the election$/ do |negate|
  visit election_ballots_url( @ballot.election )
  step %{I should#{negate} be authorized for the ballot}
  visit election_url( @ballot.election )
  if negate.blank?
    expect( page ).to have_text "List ballots"
  else
    expect( page ).to have_no_text "List ballots"
  end
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
    within("#ballot-#{@ballot.id}") { expect( page ).to have_text "Destroy" }
  end
  Capybara.current_session.driver.submit :delete, ballot_url( @ballot ), {}
  step %{I should#{negate} be authorized for the ballot}
end

Given /^I can vote in an? (un)?ranked election(?: with ([0-9]+) slots)?$/ do |unranked,slots|
  slots = slots.present? ? slots.to_i : 1
  step %{I log in as the plain user}
  @election = create(:election, name: "2012 President",
    verify_message: "Congrats on *voting*!" )
  @race = create( :race, election: @election, name: 'President',
    is_ranked: ( unranked.present? ? false : true ), slots: slots )
  @race.roll.users << @current_user
  PortraitUploader.enable_processing = true
  create :candidate, name: "Barack Obama", race: @race, statement: "The audacity of *hope*."
  create :candidate, name: "Mitt Romney", race: @race
  PortraitUploader.enable_processing = false
end

When /^I prepare a ballot that is (overchecked|double-ranked|nonconsecutive)$/ do |error|
  visit new_election_ballot_url( @election )
  within_fieldset("President") do
    case error
    when 'overchecked'
      check "Barack Obama"
      check "Mitt Romney"
    when 'double-ranked'
      select "1", from: "Barack Obama"
      select "1", from: "Mitt Romney"
    when 'nonconsecutive'
      select "2", from: "Barack Obama"
    end
  end
  click_button "Continue"
end

Then /^I should see an error about the ballot being (overchecked|double-ranked|nonconsecutive)$/ do |error|
  within("div.alert-error") do
    expect( page ).to have_text "Ballot of #{@current_user.name} for 2012 President has the following errors:"
    expect( page ).to have_text "section for President has the following errors:"
    case error
    when 'overchecked'
      expect( page ).to have_text "1 choice is selected beyond the 1 allowed for the section"
    when 'double-ranked'
      expect( page ).to have_text "vote for Barack Obama has the following errors:"
      expect( page ).to have_text "rank is not unique for the race"
      expect( page ).to have_text "vote for Mitt Romney has the following errors:"
    when 'missing a rank'
      expect( page ).to have_text "vote for Barack Obama has the following errors:"
      expect( page ).to have_text "rank is 2 but there is no vote ranked 1"
    end
  end
end


When /^I fill in an? (in)?complete (un)?ranked ballot$/ do |incomplete, unranked|
  visit new_election_ballot_url( @election )
  within_fieldset("President") do
    if unranked.present?
      check( "Barack Obama" ) unless incomplete.present?
    else
      select "1", from: "Barack Obama"
      select( "2", from: "Mitt Romney" ) unless incomplete.present?
    end
  end
  click_button "Continue"
end

Then /^I should see the confirmation page for the (in)?complete (un)?ranked ballot$/ do |incomplete, unranked|
  if incomplete.present?
    within("div.alert:nth-of-type(1)") do
      expect( page ).to have_text(
        "1 fewer choice is selected than the #{unranked.present? ? 1 : 2} " +
        "allowed for the section. Your ballot can be cast without changing " +
        "your selections for this section, but you may want to make more selections."
      )
    end
  else
    expect( page ).to have_no_selector ".alert"
  end
end

When /^I change my choices for the (in)?complete (un)?ranked ballot$/ do |incomplete, unranked|
  choose "Make changes to these choices"
  click_button "Continue"
  within_fieldset("President") do
    if unranked.present?
      uncheck "Barack Obama"
      check( "Mitt Romney" ) unless incomplete.present?
    else
      select "1", from: "Mitt Romney"
      if incomplete.present?
        select "", from: "Barack Obama"
      else
        select "2", from: "Barack Obama"
      end
    end
  end
  click_button "Continue"
end

When /^I confirm my choices$/ do
  choose "Cast my votes for these choices"
  click_button "Continue"
end

Then /^I should have successfully cast my (un)?changed (in)?complete (un)?ranked ballot$/ do |unchanged, incomplete, unranked|
  expect( page ).to have_text "Ballot cast."
  expect( page ).to have_text "Congrats on voting!"
  @ballot = Ballot.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  section = @ballot.sections.first
  if unranked.present?
    if incomplete.present?
      expect( section.votes.length ).to eql 0
    else
      expect( section.votes.length ).to eql 1
      expect( section.votes.first.candidate.name ).to eql ( unchanged.present? ? "Barack Obama" : "Mitt Romney" )
    end
  else
    if incomplete.present?
      expect( section.votes.length ).to eql 1
      expect( section.votes.first.candidate.name ).to eql ( unchanged.present? ? "Barack Obama" : "Mitt Romney" )
    else
      expect( section.votes.length ).to eql 2
      expect( section.votes.first.candidate.name ).to eql ( unchanged.present? ? "Barack Obama" : "Mitt Romney" )
      expect( section.votes.last.candidate.name ).to eql ( unchanged.present? ? "Mitt Romney" : "Barack Obama" )
    end
  end
end

When /^I start a ballot$/ do
  visit new_election_ballot_path( @election )
end

When /^I click on a candidate$/ do
  click_link "Barack Obama"
end

Then /^the candidate profile should pop up$/ do
  within("#candidate-#{@race.candidates.first.id}") do
    expect( page ).to have_text 'The audacity of hope.'
    click_button 'Close'
  end
  expect( page ).to have_no_text 'The audacity of hope.'
end

