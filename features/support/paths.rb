module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      root_path

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

    when /the login page/
      login_url

    when /the logout page/
      logout_path

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)

