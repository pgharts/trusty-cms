TrustyCms::Application.routes.draw do
  root to: 'site#show_page'
  TrustyCms::Application.config.enabled_extensions.each { |ext|
    load File.join(TrustyCms::ExtensionPath.find(ext).to_s, "config", "routes.rb")
  }
  namespace :admin do
    resources :pages do
      resources :children, :controller => 'pages'
      #TODO: put back the remove on children possibly
      get 'remove', on: :member
    end
    resources :layouts do
      get 'remove', on: :member
    end
    resources :users do
      get 'remove', on: :member
    end
  end

  match 'admin/preview' => 'admin/pages#preview', :as => :preview, :via => [:post, :put]
  namespace :admin do
    resource :preferences
    resource :configuration, :controller => 'configuration'
    resources :extensions, :only => :index
    resources :page_parts
    resources :page_fields
    match '/reference/:type(.:format)' => 'references#show', :as => :reference, :via => :get
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
