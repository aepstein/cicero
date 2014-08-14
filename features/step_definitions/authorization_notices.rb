Then /^I should( not)? be authorized$/ do |negate|
  if negate.blank?
    step %{I should not be alerted that I am unauthorized}
  else
    step %{I should be alerted that I am unauthorized}
    URI.parse(current_url).path.should eql '/'
  end
end

Then /^I should( not)? be alerted that I am unauthorized$/ do |negate|
  if negate.blank?
    find('.alert').should(
      have_text('You may not perform the requested action.') )
  else
    if page.has_selector?( '.alert' )
      find('.alert').should(
        have_no_text('You may not perform the requested action.') )
    end
  end
end

