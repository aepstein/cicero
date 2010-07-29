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

    when /^my elections page$/
      my_elections_path

    when /^the edit page for #{capture_model}$/
      edit_polymorphic_path( [model($1)] )

    when /^the (?:"(.+)" )?(?:(.+) )?#{capture_factory} page(?: for #{capture_model})?$/
      if $4.blank?
        polymorphic_path( [ $2, $3 ], :format => $1 )
      else
        polymorphic_path( [ $2, model($4), $3 ], :format => $1 )
      end

    when /^the (?:"(.+)" )?(?:(.+) )?#{capture_plural_factory} page(?: for #{capture_model})?$/
      if $4.blank?
        polymorphic_path( ($2.blank? ? [ $3 ] : [ $2, $3 ]), :format => $1 )
      else
        polymorphic_path( ($2.blank? ? [ model($4), $3 ] : [ $2, model($4), $3 ]), :format => $1 )
      end

    when /^the page for #{capture_model}$/
      polymorphic_path( [model($1)] )

    when /^the preview #{capture_factory} page for #{capture_model}$/
      polymorphic_path( ['preview', 'new', model($2), $1] )

    when /the login page/
      login_url

    when /the logout page/
      logout_path


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

