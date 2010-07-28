Factory.define :election do |f|
  f.sequence(:name) { |n| "Election #{n}" }
  f.starts_at { |r| Time.zone.now - 1.day }
  f.ends_at { |r| r.starts_at + 2.days  }
  f.results_available_at { |r| r.ends_at + 1.week }
  f.verify_message "Congratulations!"
  f.contact_name "Elections Committee"
  f.contact_email "elections@example.com"
end

Factory.define :past_election, :parent => :election do |f|
  f.starts_at { |r| Time.zone.now - 1.year }
end

Factory.define :future_election, :parent => :election do |f|
  f.starts_at { |r| Time.zone.now + 1.year }
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
end

Factory.define :user do |f|
  f.sequence(:net_id) { |n| "net#{n}" }
  f.first_name "First"
  f.last_name "Last"
  f.email { |user| "#{user.net_id}@cornell.edu" }
  f.password 'secret'
  f.password_confirmation { |user| user.password }
end

Factory.define :petitioner do |f|
  f.association :user
  f.candidate { |petitioner|
    race = Factory(:race)
    race.roll.users << petitioner.user
    petitioner.association :candidate, :race => race
  }
end

Factory.define :ballot do |f|
  f.association :election
  f.association :user
end

Factory.define :section do |f|
  f.association :ballot
  f.race { |section| section.association(:race, :election => section.ballot.election, :roll => Factory(:roll, :election => section.ballot.election, :users => [ section.ballot.user ] ) ) }
end

Factory.define :vote do |f|
  f.association :section
  f.candidate { |vote| vote.association( :candidate, :race => vote.section.race ) }
end

