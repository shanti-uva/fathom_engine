Rails.application.routes.draw do
  resources :categories do
    member do
      get :contract
      get :expand
    end
    resources :children, :controller => 'categories' do
      member do
        get :contract
        get :expand
      end
    end
  end

  #map.netbadge_sessions 'sessions/netbadge', :controller=>'sessions', :action=>'netbadge', :protocol=>(SSL_ENABLED ? 'https' : 'http')

  resources :users do
    member do
      get :unban_user
      get :ban_user
    end
  end

  resources :blacklists, :relationships, :languages, :posts
  resources :sessions, :except => [:index]
  
  #match '/netbadge_sessions' => 'sessions#netbadge', :constraints => { :protocol=>(SSL_ENABLED ? 'https' : 'http') }, :as => :netbadge_sessions
  match '/shibboleth' => 'sessions#netbadge', :constraints => { :protocol=>(SSL_ENABLED ? 'https' : 'http') }, :as => :shibboleth
  match '/testmail' => 'users#testmail', :as => :testmail
  match '/signup' => 'users#new', :as => :signup
  match '/signup_netbadge' => 'users#new_netbadge', :as => :signup_netbadge
  match '/signup_openid' => 'users#new_openid', :as => :signup_openid
  match '/openid_validate' => 'users#validate_openid', :as => :openid_validate, :via => :post 
  match '/signed_up' => 'users#pending', :as => :signed_up
  match '/turned_down' => 'users#rejected', :as => :turned_down
  match '/forgot' => 'users#forgot_password', :as => :forgot
  match '/reset/:reset_code' => 'users#reset_password', :as => :reset
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/login' => 'sessions#new', :as => :authenticated_system_login
  match '/logout' => 'sessions#destroy', :as => :authenticated_system_logout
  match '/login_page' => 'sessions#login_page', :as => :login_page
  match '/sessions' => 'sessions#create', :as => :open_id_complete
  match '/relate' => 'home#relate', :as => :relate, :defaults => { :format => 'xml'}
  match '/link_netbadge' => 'users#link_netbadge', :as => :link_netbadge
  match '/search' => 'search#index', :as => :search
  match '/regenerate_index' => 'search#regenerate_index', :as => :regenerate_index
  
  match '/add_item' => 'line_items#add_item', :as => :add_item
  
  match '/home_page' => 'home#index', :as => :home_page
  
  resources :organizations do
    resources :posts
  end

  resources :people do
    collection do
      get :profile_tags
    end
    
    resources :line_items do
      collection do
        post :add_item
      end
      member do
        get :remove_item
      end
    end
    resources :links, :posts
  end

  
  resources :tools do
    resources :posts, :people
    resources :reviews do
      collection do
        get :add_author
      end
      member do
        get :contract
        get :expand
        get :expand_show
        get :contract_show
      end
      resources :sources do
        member do
          get :contract
          get :expand
          get :expand_show
          get :contract_show
        end
        resources :translated_sources do
          collection do
            get :add_author
          end
        end
      end
    end
    resources :usage_scenarios do
      collection do
        get :add_author
      end
      member do
        get :contract
        get :expand
        get :expand_show
        get :contract_show
      end
      resources :sources do
        member do
          get :contract
          get :expand
          get :expand_show
          get :contract_show
        end
        resources :translated_sources do
          collection do
            get :add_author
          end
        end
      end
    end
    resources :sources do
      member do
        get :contract
        get :expand
        get :expand_show
        get :contract_show
      end
      resources :translated_sources do
        collection do
          get :add_author
        end      
      end
    end
  end

  
  resources :projects do
      resources :posts, :people
  end

  resources :tag_projects, :controller => 'projects', :path_prefix => 'tags/:tag_string'
  
  match '/me' => 'people#me', :as => :me
  match 'relationbrowser' => 'home#relationbrowser', :as => :relationbrowser
  match '/admin' => 'users#index', :as => :admin
  match '/admin/update_users' => 'users#update', :as => :admin_update_users
  root :to => 'home#index' # , :as => :home_page

  
  match '/:controller(/:action(/:id))'
end