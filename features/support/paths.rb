module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /^the new candidate page for #{capture_model}$/
      new_race_candidate_path(model($1))

    when /^the new roll page for #{capture_model}$/
      new_election_roll_path(model($1))

    when /^the new race page for #{capture_model}$/
      new_election_race_path(model($1))

    when /^the races page for #{capture_model}$/
      election_races_path(model($1))

    when /the login page/
      login_url

    when /the logout page/
      logout_path

    when /the new election page/
      new_election_path


    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)

