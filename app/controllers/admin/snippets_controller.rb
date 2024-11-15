class Admin::SnippetsController < Admin::ResourceController
  paginate_models
  before_action :authorize_role
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
                       when: %i[designer admin],
                       denied_url: { controller: 'admin/pages', action: 'index' },
                       denied_message: 'You must have at least editor privileges to perform this action.'
end
