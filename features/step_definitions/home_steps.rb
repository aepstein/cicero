Given /^I am enrolled in (\d+) current elections$/ do |quantity|
  @elections = if quantity > 0
    (1..quantity).map do |i|
      create(:roll, election: create(:election, name: "Election #{i}") ).users << @current_user
    end
  else
    []
  end
end

Given /^I voted in (\d+) of those elections$/ do |quantity|
  quantity.times do |i|
    create(:ballot, election: @elections[i-1], user: @current_user)
  end
end

