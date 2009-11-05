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

Factory.define :race do |f|
  f.association :election
  f.association :roll
  f.sequence(:name) { |n| "Race #{n}" }
end

