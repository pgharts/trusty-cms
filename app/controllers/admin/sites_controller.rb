class Admin::SitesController < Admin::ResourceController
  helper :sites
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must have administrative privileges to perform this action.'
  
  %w(move_higher move_lower move_to_top move_to_bottom).each do |action|
    define_method action do
      model.send(action)
      response_for :update
    end
  end
end
