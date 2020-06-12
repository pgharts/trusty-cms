TrustyCms::Application.routes.draw do
  root to: 'site#show_page'
  devise_for :users, module: :devise, skip: :registration
  as :user do
    post 'authenticate', to: 'devise/sessions#create', as: :authenticate
  end
  get '/rad_social/mail' => 'social_mailer#social_mail_form', as: :rad_social_mail_form
  post '/rad_social/mail' => 'social_mailer#create_social_mail', as: :rad_create_social_mail
  TrustyCms::Application.config.enabled_extensions.each do |ext|
  end
  namespace :admin do
    resources :pages do
      resources :children, controller: 'pages'
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
    post 'save-table-position' => 'pages#save_table_position', as: 'save_tables_position'

    resources :assets do
      get :remove, on: :member
      get :refresh, on: :collection
      put :refresh, on: :member
    end
    resources :page_attachments, only: [:new] do
      get :remove, on: :member
    end
    resources :pages do
      get :remove, on: :member
      resources :page_attachments
    end
  end

  match 'admin/preview' => 'admin/pages#preview', :as => :preview, :via => %i[post put]
  get 'admin' => 'admin/pages#index'

  namespace :admin do
    resource :preferences
    resource :configuration, controller: 'configuration'
    resources :extensions, only: :index
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

  get 'error/404' => 'site#not_found', :as => :not_found
  get 'error/500' => 'site#error', :as => :error
  get '*url' => 'site#show_page'
end
