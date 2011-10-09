ActionController::Routing::Routes.draw do |map|
  map.resources(:categories, :member => {:expand => :get, :contract => :get}) { |category| category.resources(:children, :controller => 'categories', :member => {:expand => :get, :contract => :get}) }

  
  map.netbadge_sessions 'sessions/netbadge', :controller=>'sessions', :action=>'netbadge', :protocol=>(SSL_ENABLED ? 'https' : 'http')
  
  map.resources :users, :member => {:ban_user => :get, :unban_user => :get}
  map.resources :blacklists
  
  map.resources :sessions, :except => [:index]
  map.resources :relationships
  map.resources :languages
 
  map.signup '/signup', :controller => 'users', :action => 'new'#, :protocol=>(SSL_ENABLED ? 'https' : 'http')
  map.signup_netbadge '/signup_netbadge', :controller => 'users', :action => 'new_netbadge'
  map.signup_openid '/signup_openid', :controller => 'users', :action => 'new_openid'
  map.openid_validate 'openid_validate', :controller => 'users', :action => 'validate_openid', :requirements => { :method => :post }  
  map.signed_up '/signed_up', :controller => 'users', :action => 'pending'
  map.turned_down 'turned_down', :controller => 'users', :action => 'rejected'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot_password'
  map.reset 'reset/:reset_code', :controller => 'users', :action => 'reset_password'
  
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  #hack paths for integration with thl  
  map.authenticated_system_login  'login', :controller => 'sessions', :action => 'new'
  map.authenticated_system_logout 'logout', :controller => 'sessions', :action => 'destroy'
  
  map.login_page '/login_page', :controller => 'sessions', :action => 'login_page'
  
  map.open_id_complete 'sessions', :controller => "sessions", :action => "create", 
    :requirements => { :method => :get }
                                   
  map.relate '/relate', :controller => 'home', :action => 'relate'
  
  map.link_netbadge '/link_netbadge', :controller => 'users', :action => 'link_netbadge'
  
  map.home_page '/', :controller => 'home', :action => 'index'
  
  map.search '/search', :controller =>'search', :action => 'index'
  map.regenerate_index '/regenerate_index', :controller =>'search', :action => 'regenerate_index'

  map.resources :posts

  map.resources :organizations do |organization|
    organization.resources :posts
  end

  map.resources(:people, :collection=>{:profile_tags=>:get}) do |person|
    person.resources :links
    person.resources :posts
    person.resources :line_items, :collection => {:add_item => :get}, :member => {:remove_item => :get }
  end

  map.resources :tools do |tool|
    tool.resources :posts
    tool.resources :people
    tool.resources :reviews, :collection => {:add_author => :get}, :member => {:expand => :get, :contract => :get, :expand_show => :get, :contract_show => :get} do |review|
      review.resources :sources, :member => {:expand => :get, :contract => :get, :expand_show => :get, :contract_show => :get} do |source|
        source.resources :translated_sources, :collection => {:add_author => :get}
      end
    end
    tool.resources :usage_scenarios, :collection => {:add_author => :get}, :member => {:expand => :get, :contract => :get, :expand_show => :get, :contract_show => :get} do |usage_scenario|
      usage_scenario.resources :sources, :member => {:expand => :get, :contract => :get, :expand_show => :get, :contract_show => :get} do |source|
        source.resources :translated_sources, :collection => {:add_author => :get}
      end
    end
    tool.resources :sources, :member => {:expand => :get, :contract => :get, :expand_show => :get, :contract_show => :get} do |source|
      source.resources :translated_sources, :collection => {:add_author => :get}
    end
  end
  
  map.resources :projects do |project|
    project.resources :posts
    project.resources :people
  end
  map.resources :tag_projects, :controller => 'projects', :path_prefix => 'tags/:tag_string'
  
  map.me '/me', :controller => 'people', :action => 'me', :requirements => { :method => :get }
  
  map.relationbrowser 'relationbrowser', :controller => 'home', :action => 'relationbrowser'
  
  map.admin '/admin', :controller => 'users', :action => 'index'
  map.admin_update_users '/admin/update_users', :controller => 'users', :action => 'update'
  
  #map.resources :scenario_types

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
