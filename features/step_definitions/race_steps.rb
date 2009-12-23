When /^I delete the (\d+)(?:st|nd|rd|th) race for #{capture_model}$/ do |pos, election|
  visit election_races_url model election
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following races:$/ do |expected_races_table|
  expected_races_table.diff!( tableish('table tr','th,td') )
end

