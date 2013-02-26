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
    resources :candidates, only: [ :index, :new, :create ]
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
    resources :ballots, only: [ :index ]
  end
  resource :user_session, only: [ :create ]

  match 'login', to: 'user_sessions#new', as: 'login'
  match 'logout', to: 'user_sessions#destroy', as: 'logout'
  match 'home', to: 'home#home', as: 'home'

  root to: 'home#home'
end

