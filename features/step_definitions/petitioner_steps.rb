Given /^a petitioner exists for the candidate$/ do
  user = create :user
  @candidate.race.roll.users << user
  @petitioner = create :petitioner, candidate: @candidate, user: user
end

Given /^I have an? (admin|petitioner|plain) relationship to the petitioner$/ do |relation|
  case relation
  when 'petitioner'
    @current_user = @petitioner.user
  else
    step %{I am the #{relation} user}
  end
  step %{I log in}
end

Then /^I may( not)? see the petitioner$/ do |negate|
  visit candidate_petitioners_url( @petitioner.candidate )
  if negate.blank?
    expect( page ).to have_selector "#petitioner-#{@petitioner.id}"
  else
    expect( page ).to have_no_selector "#petitioner-#{@petitioner.id}"
  end
end

Then /^I may( not)? destroy the petitioner$/ do |negate|
  visit candidate_petitioners_url( @petitioner.candidate )
  if negate.blank?
    within "#petitioner-#{@petitioner.id}" do
      expect( page ).to have_text "Destroy"
    end
  else
    if page.has_selector? "#petitioner-#{@petitioner.id}"
      within "#petitioner-#{@petitioner.id}" do
        expect( page ).to have_no_text "Destroy"
      end
    end
  end
  Capybara.current_session.driver.submit :delete, petitioner_url(@petitioner), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? create a petitioner for the candidate$/ do |negate|
  visit new_candidate_petitioner_url( @candidate )
  step %{I should#{negate} be authorized}
  visit candidate_petitioners_url( @candidate )
  if negate.blank?
    expect( page ).to have_text "New petitioner"
  else
    expect( page ).to have_no_text "New petitioner"
  end
end

When /^I create a petitioner$/ do
  @user = create :user, net_id: 'zzz999'
  @candidate.race.roll.users << @user
  visit new_candidate_petitioner_url( @candidate )
  fill_in "User", with: @user.name( :net_id )
  click_button "Create"
end

Then /^I should see the new petitioner$/ do
  within(".alert") { expect( page ).to have_text "Petitioner created." }
  within("#petitioners") { expect( page ).to have_text @user.net_id }
end

Given /^there are (\d+) petitioners for the candidate$/ do |quantity|
  step %{there are #{quantity} users}
  @candidate.race.roll.users << @users
  @petitioners = @users.map { |user| create :petitioner, candidate: @candidate, user: user }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) petitioner for the candidate$/ do |text, petitioner|
  visit candidate_petitioners_url( @candidate )
  within("table > tbody > tr:nth-child(#{petitioner.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { expect( page ).to have_text("Petitioner destroyed.") }
end

Then /^I should see the following petitioners:$/ do |table|
  table.diff! tableish( 'table#petitioners > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for petitioners for the candidate with name "([^"]+)"$/ do |needle|
  visit candidate_petitioners_url( @candidate )
  fill_in "Name", with: needle
  click_button "Search"
end

