Rails.application.routes.draw do
  resources :maps
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  # match '/places', to: 'maps#places'
  # match 'places' => 'maps#places', :via => [:get]#, :as => 'places_show'
  # resources :maps, path: 'places'

  # resources :maps, path: 'maps' do
  #   collection do
  #     get 'places'
  #   end
  # end

  get '/map' => 'maps#index'
  get '/get_places' => 'maps#get_places'
  get '/get_fishings' => 'maps#get_fishings'
  get '/get_fishing_chart_data' => 'maps#get_fishing_chart_data'
  get '/fishings' => 'fishings#index'
  get '/get_place_details' => 'maps#get_place_details'
  # get '/add_fishing' => 'add_fishing#index'
  # post 'add_fishing' => 'add_fishing#add_fishing'
  resources :add_fishing, path: 'add_fishing' do
    collection do
      get 'get'
      post 'add_fishing'
      post 'add_other'
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
