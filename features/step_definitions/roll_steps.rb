When /^I delete the (\d+)(?:st|nd|rd|th) roll for #{capture_model}$/ do |pos, election|
  visit election_rolls_url model election
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following rolls:$/ do |expected_rolls_table|
  expected_rolls_table.diff!( tableish('table tr','th,td') )
end

