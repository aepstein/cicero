When /^I delete the (\d+)(?:st|nd|rd|th) candidate for #{capture_model}$/ do |pos, race|
  visit race_candidates_url model race
  within("table > tbody > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following candidates:$/ do |expected_candidates_table|
  expected_candidates_table.diff!(table_at('table').to_a)
end

