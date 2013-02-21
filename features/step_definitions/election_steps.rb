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

