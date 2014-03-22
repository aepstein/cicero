Given /^(?:an? )(current|future|past) election exists$/ do |tense|
  @election = create("#{tense}_election".to_sym)
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

Then /^I may( not)? see the election$/ do |negate|
  visit(election_url(@election))
  step %{I should#{negate} be authorized}
  visit(elections_url)
  if negate.blank?
    page.should have_selector( "#election-#{@election.id}" )
  else
    page.should have_no_selector( "#election-#{@election.id}" )
  end
end

Then /^I may( not)? tabulate the election$/ do |negate|
  visit(election_url(@election))
  if negate.blank?
    page.should have_selector( "#results" )
  else
    page.should have_no_selector( "#results" )
  end
  visit(tabulate_election_url(@election, format: :blt))
  step %{I should#{negate} be authorized}
  race = create(:race, election: @election)
  visit(race_ballots_url(race, format: :blt))
  step %{I should#{negate} be authorized}
  race.destroy
end

Then /^I may( not)? create elections$/ do |negate|
  Capybara.current_session.driver.submit :post, elections_url, {}
  step %{I should#{negate} be authorized}
  visit(new_election_url)
  step %{I should#{negate} be authorized}
  visit(elections_url)
  if negate.blank?
    page.should have_text('New election')
  else
    page.should have_no_text('New election')
  end
end

Then /^I may( not)? update the election$/ do |negate|
  Capybara.current_session.driver.submit :put, election_url(@election), {}
  step %{I should#{negate} be authorized}
  visit(edit_election_url(@election))
  step %{I should#{negate} be authorized}
  visit(elections_url)
  if negate.blank?
    within("#election-#{@election.id}") { page.should have_text('Edit') }
  else
    page.should have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the election$/ do |negate|
  visit(elections_url)
  if negate.blank?
    within("#election-#{@election.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, election_url(@election), {}
  step %{I should#{negate} be authorized}
end

When /^I create an election$/ do
  visit new_election_path
  fill_in "Election name", with: "2008 Election"
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
  within(".alert") { page.should have_text "Election created." }
  @election = Election.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  page.should have_text "Election name: 2008 Election"
  page.should have_text "Starts at: #{@start.to_s :us_ordinal}"
  page.should have_text "Ends at: #{@end.to_s :us_ordinal}"
  page.should have_text "Results available at: #{@release.to_s :us_ordinal}"
  page.should have_text "Purge results after: #{@purge.to_s :long}"
  page.should have_text "Contact: Board of Elections <elections@example.com>"
  page.should have_text "Thank you for voting."
  click_link "Rolls"
  within("table#rolls > tbody tr:nth-of-type(1)") {
    within("td:nth-of-type(1)") { page.should have_text "City residents" }
    within("td:nth-of-type(2)") { page.should have_text "0" }
  }
end

When /^I update the election$/ do
  visit edit_election_path(@election)
  fill_in "Election name", with: "2009 Election"
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
  within(".alert") { page.should have_text "Election updated." }
  page.should have_text "Election name: 2009 Election"
  page.should have_text "Starts at: #{@start.to_s :us_ordinal}"
  page.should have_text "Ends at: #{@end.to_s :us_ordinal}"
  page.should have_text "Results available at: #{@release.to_s :us_ordinal}"
  page.should have_text "Purge results after: #{@purge.to_s :long}"
  page.should have_text "Contact: Elections Inc <el@example.com>"
  page.should have_text "Good job!"
  click_link "Races"
  page.should have_text "Race name: President"
  page.should have_text "Slots: 1"
  page.should have_text "Ranked? Yes"
  page.should have_text "Roll: City residents"
  page.should have_text "Special instructions for this race."
  page.should have_text "Barack Obama"
  page.should have_text "A thoughtful statement."
  page.should have_selector "img.candidate-thumb"
  page.should have_text "Disqualified? Yes"
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
  within(".alert") { page.should have_text("Election destroyed.") }
end

Then /^I should see the following elections:$/ do |table|
  table.diff! tableish( 'table#elections > tbody > tr', 'td:nth-of-type(1)' )
end

