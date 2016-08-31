TrustyCms::Application.routes.draw do
  root to: 'site#show_page'
  TrustyCms::Application.config.enabled_extensions.each { |ext|
    #load File.join(TrustyCms::ExtensionPath.find(ext).to_s, "config", "routes.rb")
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
    resources :password_resets
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

  get 'admin' => 'admin/welcome#index', :as => :admin
  get 'admin/welcome' => 'admin/welcome#index', :as => :welcome
  match 'admin/login' => 'admin/welcome#login', :as => :login, :via => [:get, :post]
  get 'admin/logout' => 'admin/welcome#logout', :as => :logout
  # match '/' => 'site#show_page', :url => '/' # set root to this so root_path works
  get 'error/404' => 'site#not_found', :as => :not_found
  get 'error/500' => 'site#error', :as => :error
  get '*url' => 'site#show_page'
  post 'pages/save-table-position' => "admin/pages#save_table_position", as: "save_tables_position"

end
