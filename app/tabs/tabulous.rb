Tabulous.setup do |config|
  config.tabs do
    basic = [ [ :home_tab, 'Home', home_path, true, true ] ]
    basic += [
      [ :admin_tab       ,'Administration',elections_path ,permitted_to?(:manage,:users),true ],
      [ :elections_subtab,'Elections'     ,elections_path ,true                         ,true ],
      [ :users_subtab    ,'Users'         ,users_path     ,true                         ,true ]
    ]
    basic += [
      [ :logout_tab, 'Log Out', logout_path, current_user.present?, true ],
      [ :login_tab , 'Log In' , login_path , current_user.blank?  , true ]
    ] unless sso_net_id
    basic
  end


  config.actions do
    [
      [ :home          ,:all_actions,:home_tab         ],
      [ :petitioners   ,:all_actions,:elections_subtab ],
      [ :ballots       ,:all_actions,:elections_subtab ],
      [ :elections     ,:all_actions,:elections_subtab ],
      [ :candidates    ,:all_actions,:elections_subtab ],
      [ :users         ,:all_actions,:users_subtab     ],
      [ :user_sessions ,:new        ,:login_tab        ],
      [ :user_sessions ,:create     ,:login_tab        ]
    ]
  end

  config.active_tab_clickable = true
  config.always_render_subtabs = false
  config.when_action_has_no_tab = :raise_error      # the default behavior
  config.html5 = false
  config.css.scaffolding = false
  config.tabs_ul_class = "nav nav-pills"
  config.bootstrap_style_subtabs = true
end

