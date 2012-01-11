Cicero::Application.routes.draw do
  resources :ballots, :only => [ :show, :destroy ]
  resources :candidates, :except => [ :index, :new, :create ] do
    member do
      get :popup
    end
    resources :petitioners, :only => [ :index, :new, :create ]
  end
  resources :elections do
    collection do
      get :my
    end
    resources :rolls, :only => [ :create, :new, :index ]
    resources :races, :only => [ :index, :new, :create ]
    resources :ballots, :only => [ :index, :new, :create ] do
      new do
        post :confirm
        get :preview
      end
    end
  end
  resources :petitioners, :except => [ :index, :new, :create ]
  resources :races, :except => [ :create, :new, :index ] do
    resources :ballots, :only => [ :index ]
    resources :sections, :only => [ :index ]
    resources :candidates, :only => [ :index, :new, :create ]
  end
  resources :rolls, :except => [ :index, :new, :create ] do
    resources :users, :only => [ :index, :create ] do
      new do
        get :bulk
      end
      collection do
        post :bulk_create
      end
    end
  end
  resources :users do
    resources :ballots, :only => [ :index ]
  end
  resource :user_session, :only => [ :create ]

  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'
  match 'home', :to => 'elections#my', :as => 'home'

  root :to => 'elections#my'
end

