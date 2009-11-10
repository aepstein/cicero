Given /^#{capture_model} is a current election$/ do |election|
  model(election).update_attributes( :voting_starts_at => (DateTime.now - 1.days),
    :voting_ends_at => (DateTime.now + 1.days), :results_available_at => (DateTime.now + 2.days) )
end

When /^I delete the (\d+)(?:st|nd|rd|th) election$/ do |pos|
  visit elections_url
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following elections:$/ do |expected_elections_table|
  expected_elections_table.diff!(table_at('table').to_a)
end

