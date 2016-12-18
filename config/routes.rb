ActionController::Routing::Routes.draw do |map|
  map.resources :scriptbodies
  map.resources :passwords
  map.resources :sqlxsls

  map.connect "momo/create", :controller => 'momo', :action => 'create'
  map.connect "momo/login", :controller => 'momo', :action => 'login'
  map.connect "momo/logout", :controller => 'momo', :action => 'logout'
  map.connect "momo/upload", :controller => 'momo', :action => 'upload'
  map.connect "momo/test", :controller => 'momo', :action => 'test'

#  map.connect "momo/:action", :controller => 'momo', :requiremetns => {:action => (create|login|logout)}
  map.connect "momo/:action/:id", :controller => 'momo'
  map.connect "momo/:id", :controller => 'momo', :action => 'dispatch'
  map.resources :momo
  
  map.connect "sqlxsls/:id/copy", :controller => 'sqlxsls', :action => 'copy'
  map.connect "sqlxsls/:id/destroy", :controller => 'sqlxsls', :action => 'destroy'
  
  map.connect ":author/:page.xsl", :controller => 'momo', :action => 'disp', :disp=>"xsl"
  map.connect ":author/:page", :controller => 'momo', :action => 'disp', :disp=>"normal"
  map.connect ":author/:page/:id", :controller => 'momo', :action => 'disp', :disp=>"normal"

  map.connect "/", :controller => 'momo', :action => 'logout'

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
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end