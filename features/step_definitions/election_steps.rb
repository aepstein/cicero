Given /^#{capture_model} is a current election$/ do |election|
  election = model(election)
  election.starts_at = DateTime.now - 1.weeks
  election.ends_at = election.starts_at + 2.weeks
  election.results_available_at = election.ends_at + 1.days
  election.save!
end

