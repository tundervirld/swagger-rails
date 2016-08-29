Rails.application.routes.draw do
  resources :users
  match "env" => "users#env_variables", as: :env, via: [:get, :post]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
