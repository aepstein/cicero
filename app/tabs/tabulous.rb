Tabulous.setup do
  tabs do
    home_tab do
      text { 'Home' }
      link_path { home_path }
      visible_when { true }
      enabled_when { true }
      active_when do
        in_action('any').of_controller('home')
        in_action('sso_failure').of_controller('user_sessions')
      end
    end
    admin_tab do
      text { 'Administration' }
      link_path { elections_path }
      visible_when { permitted_to?( :manage, :users ) }
      enabled_when { true }
      active_when do
        a_subtab_is_active
      end
    end
    elections_subtab do
      text { 'Elections' }
      link_path { elections_path }
      visible_when { true }
      enabled_when { true }
      active_when do
        in_action('any').of_controller('elections')
        in_action('any').of_controller('petitioners')
        in_action('any').of_controller('ballots')
        in_action('any').of_controller('candidates')
      end
    end
    users_subtab do
      text { 'Users' }
      link_path { users_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('users') }
    end
    logout_tab do
      text { 'Log Out' }
      link_path { logout_path }
      visible_when { current_user.present? }
      enabled_when { true }
      active_when { in_actions('destroy').of_controller('user_sessions') }
    end
    login_tab do
      text { 'Log In' }
      link_path { login_path }
      visible_when { current_user.blank? }
      enabled_when { true }
      active_when { in_actions('new','create').of_controller('user_sessions') }
    end
  end
  
  customize do
    active_tab_clickable true
    when_action_has_no_tab :raise_error
    renderer :bootstrap_navbar
  end  
end
