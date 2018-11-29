Rails.application.routes.draw do
  get 'sessions/new'

  root 'static_pages#home'
  
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'

  get  '/charge',  to: 'static_pages#donate'
  #get  '/charges',  to: 'static_pages#confirmation'
  #post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'


 # post 'users/search' => 'users#search', as: 'search_users'

  resources :users
  resources :posts,          only: [:create, :destroy]
  resources :charges
end