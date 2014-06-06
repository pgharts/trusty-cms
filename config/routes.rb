TrustyCms::Application.routes.draw do
  root to: 'site#show_page'
  namespace :admin, :member => { :remove => :get } do
    resources :pages do


      resources :children
    end
    resources :layouts
    resources :users
  end

  match 'admin/preview' => 'admin/pages#preview', :as => :preview, :via => [:post, :put]
  namespace :admin do
    resource :preferences
    resource :configuration
    resources :extensions, :only => :index
    resources :page_parts
    resources :page_fields
    match '/reference/:type.:format' => 'references#show', :as => :reference, :via => :get
  end

  match 'admin' => 'admin/welcome#index', :as => :admin
  match 'admin/welcome' => 'admin/welcome#index', :as => :welcome
  match 'admin/login' => 'admin/welcome#login', :as => :login
  match 'admin/logout' => 'admin/welcome#logout', :as => :logout
  # match '/' => 'site#show_page', :url => '/' # set root to this so root_path works
  match 'error/404' => 'site#not_found', :as => :not_found
  match 'error/500' => 'site#error', :as => :error
  match '*url' => 'site#show_page'
end