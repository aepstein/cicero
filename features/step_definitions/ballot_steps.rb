When /^I delete the (\d+)(?:st|nd|rd|th) ballot for #{capture_model}$/ do |pos, election|
  visit election_ballots_url model election
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following ballots:$/ do |expected_ballots_table|
  expected_ballots_table.diff!( tableish('table tr','th,td') )
end

