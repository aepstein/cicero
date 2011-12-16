FactoryGirl.define do
  factory :election do
    sequence(:name) { |n| "Election #{n}" }
    starts_at { Time.zone.now - 1.day }
    ends_at { starts_at + 2.days  }
    results_available_at { ends_at + 1.week }
    verify_message "Congratulations!"
    contact_name "Elections Committee"
    contact_email "elections@example.com"

    factory :past_election do
      starts_at { Time.zone.now - 1.year }
#      ends_at { starts_at + 2.days  }
#      results_available_at { ends_at + 1.week }
    end

    factory :future_election do
      starts_at { Time.zone.now + 1.year }
#      ends_at { starts_at + 2.days  }
#      results_available_at { ends_at + 1.week }
    end
  end

  factory :roll do
    association :election
    sequence(:name) { |n| "Roll #{n}" }
  end

  factory :race do
    association :election
    roll { association(:roll, :election => election) }
    sequence(:name) { |n| "Race #{n}" }
    is_ranked false
  end

  factory :candidate do
    association :race
    sequence(:name) { |n| "Candidate #{n}" }
  end

  factory :user do
    sequence(:net_id) { |n| "net#{n}" }
    first_name "First"
    last_name "Last"
    email { "#{net_id}@cornell.edu" }
    password 'secret'
    password_confirmation { password }
  end

  factory :petitioner do
    association :user
    candidate do
      race = association(:race)
      race.roll.users << user
      association :candidate, :race => race
    end
  end

  factory :ballot do
    association :election
    association :user
  end

  factory :section do
    association :ballot
    race do
      association( :race, :election => ballot.election,
        :roll => association(:roll, :election => ballot.election,
        :users => [ ballot.user ] ) )
    end
  end

  factory :vote do
    association :section
    rank 1
    candidate { association( :candidate, :race => section.race ) }
  end
end

