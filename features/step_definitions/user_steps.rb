Given /^(?:an? )user exists to whom I have an? (admin|staff|owner|plain) relationship$/ do |relationship|
  role = case relationship
  when 'admin'
    'admin'
  when 'staff'
    'staff'
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  case relationship
  when 'owner'
    @user = @current_user
  else
    @user = create( :user )
  end
end

Then /^I may( not)? see the user$/ do |negate|
  visit(user_url(@user))
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    page.should have_selector( "#user-#{@user.id}" )
  else
    page.should have_no_selector( "#user-#{@user.id}" )
  end
end

Then /^I may( not)? create users$/ do |negate|
  visit new_user_url
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    page.should have_text('New user')
  else
    page.should have_no_text('New user')
  end
  Capybara.current_session.driver.submit :post, users_url, {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? update the user$/ do |negate|
  Capybara.current_session.driver.submit :put, user_url(@user), {}
  step %{I should#{negate} be authorized}
  visit(edit_user_url(@user))
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    within("#user-#{@user.id}") { page.should have_text('Edit') }
  else
    if page.has_selector? "#user-#{@user.id}"
      within("#user-#{@user.id}") { page.should have_no_text('Edit') }
    end
  end
end

Then /^I may( not)? destroy the user$/ do |negate|
  visit(users_url)
  if negate.blank?
    within("#user-#{@user.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, user_url(@user), {}
  step %{I should#{negate} be authorized}
end

When /^I create a user as (admin|staff)$/ do |role|
  create :roll, name: "Current Roll", election: create(:current_election, name: "Current Election")
  @past_roll = create( :roll, name: "Past Roll", election: create(:past_election, name: "Past Election") )
  visit new_user_path
  fill_in "First name", with: "Andrew"
  fill_in "Last name", with: "White"
  fill_in "Net id", with: "fake"
  fill_in "Email", with: "jd@example.com"
  if role == 'admin'
    within_control_group("Administrator?") { choose "Yes" }
#    within_control_group("Staff?") { choose "Yes" }
  else
    within_control_group("Administrator?") { page.should have_selector "input.disabled" }
#    within_control_group("Staff?") { page.should have_selector "input.disabled" }
  end
  within_fieldset("Current Election") do
    check "Current Roll"
  end
  page.should have_no_fieldset "Past Election"
  click_button 'Create'
  @user = User.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new user as (admin|staff)$/ do |role|
  within( ".alert" ) { page.should have_text( "User created." ) }
  within( "#user-#{@user.id}" ) do
    page.should have_text "First name: Andrew"
    page.should have_text "Last name: White"
    page.should have_text "Email: jd@example.com"
    if role == 'admin'
      page.should have_text "Administrator? Yes"
#      page.should have_text "Staff? Yes"
    else
      page.should have_text "Administrator? No"
#      page.should have_text "Staff? No"
    end
  end
end

When /^I fill in the user as (admin|staff|owner)$/ do |role|
  fill_in "First name", with: "David"
  fill_in "Last name", with: "Skorton"
  fill_in "Email", with: "dj@example.com"
  if role == 'admin'
    within_control_group("Administrator?") { choose "No" }
#    within_control_group("Staff?") { choose "No" }
  else
    within_control_group("Administrator?") { page.should have_selector "input.disabled" }
#    within_control_group("Staff?") { page.should have_selector "input.disabled" }
  end
  if role == 'owner'
  else
  end
  within_fieldset("Current Election") do
    uncheck "Current Roll"
  end
end

When /^I update the user as (admin|staff|owner)$/ do |role|
  @past_roll.users << @user
  visit(edit_user_path(@user))
  step %{I fill in the user as #{role}}
  click_button 'Update'
end

Then /^I should see the edited user as (admin|staff|owner)$/ do |role|
  within('.alert') { page.should have_text( "User updated." ) }
  within("#user-#{@user.id}") do
    page.should have_text "First name: David"
    page.should have_text "Last name: Skorton"
    page.should have_text "Email: dj@example.com"
    page.should have_text "Administrator? No"
    page.should have_no_text "Current Election"
    page.should have_no_text "Current Roll"
    if role == 'owner'
    else
    end
  end
  @user.association(:rolls).reset
  @user.rolls.should include @past_roll
end

Given /^there are (\d+) users$/ do |quantity|
  @users = quantity.to_i.downto(1).
    map { |i| create :user, first_name: "Sequenced3#{i+2}", last_name: "User 1#{i}", net_id: "faker2#{i+1}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) user$/ do |text, user|
  visit users_url
  within("table > tbody > tr:nth-child(#{user.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { page.should have_text("User destroyed.") }
end

Then /^I should see the following users:$/ do |table|
  table.diff! tableish( 'table#users > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for users with name "([^"]+)"$/ do |needle|
  visit(users_url)
  fill_in "Name", with: needle
  click_button "Search"
end

When /^I set users for the roll via (text|attachment)$/ do |method|
  @user = create(:user, net_id: 'faker1')
  visit bulk_new_roll_user_url @roll
  values = [ %w( faker1 faker1@cornell.edu Jane Doe ), %w( faker2 faker2@cornell.edu John Doe ) ]
  path = "#{temporary_file_path}/users.csv"
  if method == 'text'
    fill_in 'users', with: CSV.generate { |csv| values.each { |v| csv << v } }
  else
    file = CSV.open("#{temporary_file_path}/users.csv",'w') do |csv|
      values.each { |v| csv << v }
      csv
    end
    $temporary_files << file
    attach_file "users_file", file.path
  end
  click_button "Import users"
end

Then /^I should see users enrolled$/ do
  within(".alert") { page.should have_text "Processed new voters: 2 new voters and 1 new users." }
  @roll.users.should include( @user, User.find_by_net_id( 'faker2' ) )
end

