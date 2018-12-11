Rails.application.routes.draw do


  #controller
  devise_for :users, controllers: { registrations: "registrations" }

  root to: "campaigns#home"
  get 'dashboard', to: 'campaigns#dashboard'
  get 'search', to: 'pages#search', :as => 'search_page'
  #get 'users', to: 'pages#search'
  get 'terms', to: 'pages#terms'
  get 'stripe_accounts/full', to: 'stripe_accounts#full'
  get 'debit_cards/new'
  post 'debit_cards/create', to: 'debit_cards#create'
  post 'debit_cards/destroy', to: 'debit_cards#destroy'
  post 'disputes', to: 'disputes#create'
  post 'instant_transfer', to: 'debit_cards#transfer'
  get 'payouts/:id', to: 'payouts#show', as: 'payout'
  post 'webhooks/stripe', to: 'webhooks#stripe'
  
 
  resources :users

  resources :campaigns

  resources :stripe_accounts

  resources :charges

  resources :bank_accounts
end
