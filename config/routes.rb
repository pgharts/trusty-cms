TrustyCms::Application.routes.draw do
  root to: 'site#show_page'

  get '/rad_social/mail' => 'social_mailer#social_mail_form', as: :rad_social_mail_form
  post '/rad_social/mail' => 'social_mailer#create_social_mail', as: :rad_create_social_mail
  TrustyCms::Application.config.enabled_extensions.each { |ext|
  }
  namespace :admin do
    resources :pages do
      resources :children, :controller => 'pages'
      get 'remove', on: :member
    end
    resources :layouts do
      get 'remove', on: :member
    end
    resources :users do
      get 'remove', on: :member
    end
    resources :snippets do
      get :remove, on: :member
    end
    resources :password_resets
    post 'save-table-position' => "pages#save_table_position", as: "save_tables_position"

    resources :assets do
      get :remove, on: :member
      get :refresh, on: :collection
      post :regenerate, on: :collection
      put :refresh, on: :member
    end
    resources :page_attachments, :only => [:new] do
      get :remove, on: :member
    end
    resources :pages do
      get :remove, on: :member
      resources :page_attachments
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

    resources :sites do
      get :remove, on: :member
      post :move_higher, on: :member
      post :move_lower, on: :member
      put :move_to_top, on: :member
      put :move_to_bottom, on: :member
    end
  end

  get 'admin' => 'admin/welcome#index', :as => :admin
  get 'admin/welcome' => 'admin/welcome#index', :as => :welcome
  match 'admin/login' => 'admin/welcome#login', :as => :login, :via => [:get, :post]
  get 'admin/logout' => 'admin/welcome#logout', :as => :logout
  get 'error/404' => 'site#not_found', :as => :not_found
  get 'error/500' => 'site#error', :as => :error
  get '*url' => 'site#show_page'

end
