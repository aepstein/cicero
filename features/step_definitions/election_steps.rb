When /^I delete the (\d+)(?:st|nd|rd|th) election$/ do |pos|
  visit elections_url
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following elections:$/ do |expected_elections_table|
  expected_elections_table.diff!(table_at('table').to_a)
end

