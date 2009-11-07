Factory.define :election do |f|
  f.sequence(:name) { |n| "Election #{n}" }
  f.voting_starts_at DateTime.now - 1.days
  f.voting_ends_at DateTime.now + 1.days
  f.results_available_at DateTime.now + 2.days
  f.verify_message "Congratulations!"
  f.contact_name "Elections Committee"
  f.contact_email "elections@example.com"
  f.contact_info "Additional contact information"
end

Factory.define :roll do |f|
  f.association :election
  f.sequence(:name) { |n| "Roll #{n}" }
end

Factory.define :race do |f|
  f.association :election
  f.roll { |race| race.association(:roll, :election => race.election) }
  f.sequence(:name) { |n| "Race #{n}" }
  f.is_ranked false
end

Factory.define :candidate do |f|
  f.association :race
  f.sequence(:name) { |n| "Candidate #{n}" }
  f.picture { ActionController::TestUploadedFile.new('spec/assets/robin.jpg','image/jpeg') }
end

Factory.define :user do |f|
  f.sequence(:net_id) { |n| "net#{n}" }
  f.first_name "First"
  f.last_name "Last"
  f.email { |user| "#{user.net_id}@cornell.edu" }
end

Factory.define :ballot do |f|
  f.association :election
  f.association :user
end

Factory.define :vote do |f|
  f.association :candidate
  f.ballot { |vote| vote.association( :ballot, :election => vote.candidate.race.election ) }
end

