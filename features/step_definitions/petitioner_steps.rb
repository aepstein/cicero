When /^I delete the (\d+)(?:st|nd|rd|th) petitioner for #{capture_model}$/ do |pos, candidate|
  visit candidate_petitioners_url model candidate
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following petitioners:$/ do |expected_petitioners_table|
  expected_petitioners_table.diff!(table_at('table').to_a)
end

