Given /^(?:an? )(current|future|past) election exists$/ do |tense|
  @election = create("#{tense}_election".to_sym)
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
  fill_in "Election Name", with: "2008 Election"
  @start = (Time.zone.now + 1.day).floor
  @end = @start + 1.day
  @release = @end + 1.day
  fill_in "Starts at", with: @start.to_s(:us_short)
  fill_in "Ends at", with: @end.to_s(:us_short)
  fill_in "Results available at", with: @release.to_s(:us_short)
  fill_in "Contact name", with: "Board of Elections"
  fill_in "Contact email", with: "elections@example.com"
  fill_in "Verify message", with: "Thank you for *voting*."
  click_button "Create"
end

Then /^I should see the new election$/ do
  within(".alert") { page.should have_text "Election created." }
  @election = Election.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  page.should have_text "Election name: 2008 Election"
  page.should have_text "Starts at: #{@start.to_s :long_ordinal}"
  page.should have_text "Ends at: #{@end.to_s :long_ordinal}"
  page.should have_text "Results available at: #{@release.to_s :long_ordinal}"
  page.should have_text "Contact: Board of Elections <elections@example.com>"
  page.should have_text "Thank you for voting."
end

When /^I update the election$/ do
  visit edit_election_path(@election)
  fill_in "Election Name", with: "2009 Election"
  @start += 1.day
  @end += 1.day
  @release += 1.day
  fill_in "Starts at", with: @start.to_s(:us_short)
  fill_in "Ends at", with: @end.to_s(:us_short)
  fill_in "Results available at", with: @release.to_s(:us_short)
  fill_in "Contact name", with: "Elections Inc"
  fill_in "Contact email", with: "el@example.com"
  fill_in "Verify message", with: "Good job!"
  click_button "Update"
end

Then /^I should see the edited election$/ do
  within(".alert") { page.should have_text "Election updated." }
  page.should have_text "Election name: 2009 Election"
  page.should have_text "Starts at: #{@start.to_s :long_ordinal}"
  page.should have_text "Ends at: #{@end.to_s :long_ordinal}"
  page.should have_text "Results available at: #{@release.to_s :long_ordinal}"
  page.should have_text "Contact: Elections Inc <el@example.com>"
  page.should have_text "Good job!"
end

