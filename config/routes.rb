Magic::Application.routes.draw do
  get '/cash' => "users#cash"
  
  match 'pusher/auth' => "pusher#auth"
  
  resources :questions do
    collection do
      get :free
      get :paid
    end
    member do
      put :vote_for
      put :vote_against
      put :follow
      put :favorite
    end
    get 'page/:page', :action => :index, :on => :collection
    resources :answers, :only => [] do
      member do
        get :accept
      end
    end
  end
  resources :answers do
    member do
      put :vote_for
      put :vote_against
    end
  end
  
  devise_for :users
  
  resources :users do
    collection do
      put :update_attribute_on_the_spot
    end
    member do
      put :follow
      get :myquestions
      get :myanswers
      get :winquestions
      get :favourites
      get :watches
      get :followings
      get :followers
    end
  end
  
  resources :recharge do
    collection do
      post :notify
      get :done
      post :generate_order
    end
  end
  
  resources :accounts
  
  resources :photos
  
  resources :messages do
    collection do
      get :load_conversations
      get :load_contact_list
      get :load_messages_on_navbar
      post :send_message
      post :update_last_viewed
    end
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
  root :to => 'questions#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
