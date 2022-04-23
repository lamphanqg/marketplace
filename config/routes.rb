Rails.application.routes.draw do
  namespace :v1 do
    resources :users
    post "/login", to: "authentication#login"
  end
end
