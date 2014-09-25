Cicero::Application.routes.draw do
  resources :ballots, only: [ :show, :destroy ]
  resources :candidates, only: [ :show ] do
    member do
      get :popup
    end
    resources :petitioners, only: [ :index, :new, :create ]
  end
  resources :elections do
    collection do
      get :my
    end
    member do
      get :tabulate
    end
    resources :ballots, only: [ :index, :new, :create ] do
      new do
        post :confirm
        get :preview
      end
    end
  end
  resources :petitioners, except: [ :index, :new, :create ]
  resources :races, only: [] do
    resources :ballots, only: [ :index ]
  end
  resources :rolls, only: [] do
    resources :users, only: [ :index, :create ] do
      new do
        get :bulk
      end
      collection do
        post :bulk_create
      end
    end
  end
  resources :users do
    collection do
      get :admin
    end
    resources :ballots, only: [ :index ]
  end
  resource :user_session, only: [ :create ]

  get 'sso_failure', to: 'user_sessions#sso_failure', as: 'sso_failure'
  get 'login', to: 'user_sessions#new', as: 'login'
  get 'logout', to: 'user_sessions#destroy', as: 'logout'
  get 'home', to: 'home#home', as: 'home'

  root to: 'home#home'
end

