Then /^I should( not)? be authorized$/ do |negate|
  if negate.blank?
    step %{I should not be alerted that I am unauthorized}
  else
    step %{I should be alerted that I am unauthorized}
    expect( URI.parse(current_url).path ).to eql '/'
  end
end

Then /^I should( not)? appear to be authorized$/ do |negate|
  if negate.blank?
    step %{I should not be alerted that I am unauthorized}
  else
    step %{I should be alerted that I am unauthorized}
  end
end

Then /^I should( not)? be alerted that I am unauthorized$/ do |negate|
  if negate.blank?
    expect( find('.alert') ).to(
      have_text('You may not perform the requested action.') )
  else
    if page.has_selector?( '.alert' )
      expect( find('.alert') ).to(
        have_no_text('You may not perform the requested action.') )
    end
  end
end

