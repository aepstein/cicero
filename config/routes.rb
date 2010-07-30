ActionController::Routing::Routes.draw do |map|
  map.resource :user_session, :only => [ :create ]
  map.resources :users, :shallow => true do |user|
    user.resources :ballots, :only => [ :index ]
  end
  map.resources :elections, :shallow => true, :collection => { :my => :get } do |election|
    election.resources :rolls do |roll|
      roll.resources :users, :new => { :bulk => :get }, :only => [ :index, :create ],
        :collection => { :bulk_create => :post }
    end
    election.resources :races do |race|
      race.resources :ballots, :only => [ :index ]
      race.resources :sections, :only => [ :index ]
      race.resources :candidates, :member => { :popup => :get } do |candidate|
        candidate.resources :petitioners
      end
    end
    election.resources :ballots, :new => [ :confirm, :preview ], :except => [ :edit, :update ]
  end

  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'

  map.root :controller => 'elections', :action => 'my'
end

