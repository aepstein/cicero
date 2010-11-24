Cicero::Application.routes.draw do
  shallow do
    resource :user_session, :only => [ :create ]
    resources :users do
      resources :ballots, :only => [ :index ]
    end
    resources :elections do
      collection do
        get :my
      end
      resources :rolls do
        resources :users, :only => [ :index, :create ] do
          new do
            get :bulk
          end
          collection do
            post :bulk_create
          end
        end
      end
      resources :races do
        resources :ballots, :only => [ :index ]
        resources :sections, :only => [ :index ]
        resources :candidates do
          member do
            get :popup
          end
          resources :petitioners
        end
      end
      resources :ballots, :except => [ :edit, :update ] do
        new do
          post :confirm
          get :preview
        end
      end
    end
  end

  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'

  root :to => 'elections#my'
end

