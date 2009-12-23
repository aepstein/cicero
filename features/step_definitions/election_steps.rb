Given /^#{capture_model} is a current election$/ do |election|
  election = model(election)
  election.starts_at = DateTime.now - 1.weeks
  election.ends_at = election.starts_at + 2.weeks
  election.results_available_at = election.ends_at + 1.days
  election.save!
end

When /^I delete the (\d+)(?:st|nd|rd|th) election$/ do |pos|
  visit elections_url
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following elections:$/ do |expected_elections_table|
  expected_elections_table.diff!( tableish('table tr','th,td') )
end

