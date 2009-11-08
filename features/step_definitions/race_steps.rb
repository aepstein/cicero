Given /^the following races:$/ do |races|
  Race.create!(races.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) race$/ do |pos|
  visit races_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following races:$/ do |expected_races_table|
  expected_races_table.diff!(table_at('table').to_a)
end
