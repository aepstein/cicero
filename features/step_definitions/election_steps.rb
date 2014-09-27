Given /^(?:an? )(current|future|past) (public |private )?election exists$/ do |tense, exposure|
  @election = create("#{tense}_election".to_sym)
  if exposure == "private "
    @election.update_column :confidential, true
  end
end

Given /^I have an? (admin|voter|plain) relationship to the election$/ do |relation|
  case relation
  when 'admin', 'plain'
    step %{I log in as the #{relation} user}
  else
    step %{I log in as the plain user}
  end
  if relation == 'voter'
    create(:roll, election: @election).users << @current_user
  end
end

Given /^I may( not)? vote in the election$/ do |negate|
  if negate.blank?
    create(:roll, election: @election).users << @current_user
  end
end


Then /^I may( not)? see the election$/ do |negate|
  visit(election_url(@election))
  step %{I should#{negate} appear to be authorized}
  visit(elections_url)
  if negate.blank?
    expect( page ).to have_selector( "#election-#{@election.id}" )
  else
    expect( page ).to have_no_selector( "#election-#{@election.id}" )
  end
end

Then /^I may( not)? tabulate the election$/ do |negate|
  visit(election_url(@election))
  if negate.blank?
    expect( page ).to have_selector( "#results" )
  else
    expect( page ).to have_no_selector( "#results" )
  end
  visit(tabulate_election_url(@election, format: :csv))
  step %{I should#{negate} appear to be authorized}
  race = create(:race, election: @election)
  visit(race_ballots_url(race, format: :blt))
  step %{I should#{negate} appear to be authorized}
  race.destroy
end

Then /^I may( not)? create elections$/ do |negate|
  Capybara.current_session.driver.submit :post, elections_url, {}
  step %{I should#{negate} appear to be authorized}
  visit(new_election_url)
  step %{I should#{negate} appear to be authorized}
  visit(elections_url)
  if negate.blank?
    expect( page ).to have_text('New election')
  else
    expect( page ).to have_no_text('New election')
  end
end

Then /^I may( not)? update the election$/ do |negate|
  Capybara.current_session.driver.submit :put, election_url(@election), {}
  step %{I should#{negate} appear to be authorized}
  visit(edit_election_url(@election))
  step %{I should#{negate} appear to be authorized}
  visit(elections_url)
  if negate.blank?
    within("#election-#{@election.id}") { expect( page ).to have_text('Edit') }
  else
    expect( page ).to have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the election$/ do |negate|
  visit(elections_url)
  if negate.blank?
    within("#election-#{@election.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, election_url(@election), {}
  step %{I should#{negate} appear to be authorized}
end

When /^I create an election$/ do
  visit new_election_path
  fill_in "Election name", with: "2008 Election"
  within_control_group("Confidential?") { choose "Yes" }
  @start = (Time.zone.now + 1.day).floor
  @end = @start + 1.day
  @release = @end + 1.day
  @purge = ( @release + 2.months ).to_date
  fill_in "Starts at", with: @start.to_s(:datetime_picker)
  fill_in "Ends at", with: @end.to_s(:datetime_picker)
  fill_in "Results available at", with: @release.to_s(:datetime_picker)
  fill_in "Purge results after", with: @purge.to_s(:date_picker)
  fill_in "Contact name", with: "Board of Elections"
  fill_in "Contact email", with: "elections@example.com"
  fill_in "Verify message", with: "Thank you for *voting*."
  click_link "Add Roll"
  within_fieldset("New roll") {
    fill_in "Roll name", with: "City residents"
  }
  click_button "Create"
end

Then /^I should see the new election$/ do
  within(".alert") { expect( page ).to have_text "Election created." }
  @election = Election.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  expect( page ).to have_text "Election name: 2008 Election"
  expect( page ).to have_text "Confidential? Yes"
  expect( page ).to have_text "Starts at: #{@start.to_s :us_ordinal}"
  expect( page ).to have_text "Ends at: #{@end.to_s :us_ordinal}"
  expect( page ).to have_text "Results available at: #{@release.to_s :us_ordinal}"
  expect( page ).to have_text "Purge results after: #{@purge.to_s :long}"
  expect( page ).to have_text "Contact: Board of Elections <elections@example.com>"
  expect( page ).to have_text "Thank you for voting."
  click_link "Rolls"
  within("table#rolls > tbody tr:nth-of-type(1)") {
    within("td:nth-of-type(1)") { expect( page ).to have_text "City residents" }
    within("td:nth-of-type(2)") { expect( page ).to have_text "0" }
  }
end

When /^I update the election$/ do
  visit edit_election_path(@election)
  fill_in "Election name", with: "2009 Election"
  within_control_group("Confidential?") { choose "No" }
  @start += 1.day
  @end += 1.day
  @release += 1.day
  @purge += 1.day
  fill_in "Starts at", with: @start.to_s(:datetime_picker)
  fill_in "Ends at", with: @end.to_s(:datetime_picker)
  fill_in "Results available at", with: @release.to_s(:datetime_picker)
  fill_in "Purge results after", with: @purge.to_s(:date_picker)
  fill_in "Contact name", with: "Elections Inc"
  fill_in "Contact email", with: "el@example.com"
  fill_in "Verify message", with: "Good job!"
  click_link "Add Race"
  within_fieldset("New race") {
    fill_in "Name", with: "President"
    fill_in "Slots", with: 1
    within_control_group("Ranked?") { choose "Yes" }
    select "City residents", from: "Roll"
    fill_in "Description", with: "*Special* instructions for this race."
    click_link "Add Candidate"
    within_fieldset("New candidate") {
      fill_in "Name", with: "Barack Obama"
      fill_in "Statement", with: "A *thoughtful* statement."
      attach_file 'Picture', File.expand_path('spec/assets/robin.jpg')
      within_control_group("Disqualified?") { choose "Yes" }
    }
  }
  click_button "Update"
end

Then /^I should see the edited election$/ do
  within(".alert") { expect( page ).to have_text "Election updated." }
  expect( page ).to have_text "Election name: 2009 Election"
  expect( page ).to have_text "Confidential? No"
  expect( page ).to have_text "Starts at: #{@start.to_s :us_ordinal}"
  expect( page ).to have_text "Ends at: #{@end.to_s :us_ordinal}"
  expect( page ).to have_text "Results available at: #{@release.to_s :us_ordinal}"
  expect( page ).to have_text "Purge results after: #{@purge.to_s :long}"
  expect( page ).to have_text "Contact: Elections Inc <el@example.com>"
  expect( page ).to have_text "Good job!"
  click_link "Races"
  expect( page ).to have_text "Race name: President"
  expect( page ).to have_text "Slots: 1"
  expect( page ).to have_text "Ranked? Yes"
  expect( page ).to have_text "Roll: City residents"
  expect( page ).to have_text "Special instructions for this race."
  expect( page ).to have_text "Barack Obama"
  expect( page ).to have_text "A thoughtful statement."
  expect( page ).to have_selector "img.candidate-thumb"
  expect( page ).to have_text "Disqualified? Yes"
end


Given /^there are (\d+) elections$/ do |quantity|
  @elections = quantity.to_i.downto(1).
    map { |i| create :election, name: "election #{i}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) election$/ do |text, election|
  visit(elections_url)
  within("table > tbody > tr:nth-child(#{election.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { expect( page ).to have_text("Election destroyed.") }
end

Then /^I should see the following elections:$/ do |table|
  table.diff! tableish( 'table#elections > tbody > tr', 'td:nth-of-type(1)' )
end

