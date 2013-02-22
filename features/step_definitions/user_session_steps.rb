Given /^I log in with net_id: "([^"]+)" and password: "([^"]+)"$/ do |net_id, password|
  unless net_id.blank?
    visit login_path
    fill_in "Net", with: net_id
    fill_in "Password", with: password
    click_button "Login"
  end
end

Given /^I am the (admin|plain) user$/ do |role|
  @current_user = case role
  when 'admin'
    create :user, admin: true, first_name: "Senior", last_name: "Administrator"
  when 'staff'
    create :user, staff: true
  else
    create :user
  end
end

When /^I log in$/ do
  step %{I log in with net_id: "#{@current_user.net_id}" and password: "secret"}
end

Given /^I log in as the (admin|plain) user$/ do |role|
  step %{I am the #{role} user}
  step %{I log in}
end

When /^I log out$/ do
  visit logout_path
end

