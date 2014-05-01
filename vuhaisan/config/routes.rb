Vuhaisan::Application.routes.draw do
  scope "admin" do
    resources :products
    resources :categories
    resources :admin_sessions, only: [:new, :create]
    resources :settei, only: [:edit, :update]
    resources :users, only: [:index]
    resources :orders, only: [:index, :edit, :update]
    match "logout", to: "admin_sessions#logout", as: :admin_logout
    match "categories_index_update/:id", to: "categories#categories_index_update", as: :admin_categories_index_update
  end

  scope "client" do
    match "home", to: "client#home", as: :client_home
    match "product/:id", to: "client#product_detail", as: :client_product_detail
    match "add_to_cart", to: "client#add_to_cart", as: :client_add_to_cart
    match "add_to_cart_remote", to: "client#add_to_cart_remote", as: :client_add_to_cart_remote, format: :js
    match "remove_from_cart_remote", to: "client#remove_from_cart_remote", as: :client_remove_from_cart_remote_remote, format: :js
    match "cart", to: "client#cart_detail", as: :client_cart_detail
    match "pay", to: "client#pay", as: :client_pay
    match "profile", to: "client#profile", as: :client_profile
    match "update_profile", to: "client#update_profile", as: :client_update_profile
    match "login_remote", to: "client#login_remote", as: :client_login_remote, format: :js
    match "logout", to: "client#logout", as: :client_logout
    match "logout_remote", to: "client#logout_remote", as: :client_logout_remote
    match "update_order_delivery_info", to: "client#update_order_delivery_info", as: :client_update_order_delivery_info
    match "delete_cart", to: "client#delete_cart", as: :client_delete_cart
    match "order/:code", to: "client#order", as: :client_order
  end
  scope "payment" do
    match "vtc", to: "payment#vtc", as: :payment_vtc
  end
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
