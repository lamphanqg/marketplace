Rails.application.routes.draw do
  namespace :v1 do
    post "purchases", to: "purchases#create"
    resources :products do
      member do
        patch "add_quantity", to: "products#add_quantity"
      end
    end
    get "my_products", to: "products#my_products"

    resources :users
    post "/login", to: "authentication#login"
  end
end
