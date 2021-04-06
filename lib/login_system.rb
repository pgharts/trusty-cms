module LoginSystem
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      # prepend_before_action :authenticate
      # prepend_before_action :authorize
      # helper_method :current_user
    end
  end

  protected

  # def current_user
  # end

  # def current_user=(value=nil)
  #   if value && value.is_a?(User)
  #     @current_user = value
  #     session['user_id'] = value.id
  #   else
  #     @current_user = nil
  #     session['user_id'] = nil
  #   end
  #   @current_user
  # end

  def authenticate
    # puts _process_action_callbacks.map(&:filter)
    # if current_user
    #   session['user_id'] = current_user.id
    #   true
    # else
    #   session[:return_to] = request.original_url
    #   respond_to do |format|
    #     format.html { redirect_to login_url }
    #     format.any(:xml,:json) { request_http_basic_authentication }
    #   end
    #   false
    # end
    true
  end

  def authorize
    # puts _process_action_callbacks.map(&:filter)
    # action = action_name.to_s.intern
    # if user_has_access_to_action?(action)
    #   true
    # else
    #   permissions = self.class.controller_permissions[action]
    #   flash[:error] = permissions[:denied_message] || 'Access denied.'
    #   respond_to do |format|
    #     format.html { redirect_to(permissions[:denied_url] || { :action => :index }) }
    #     format.any(:xml, :json) { head :forbidden }
    #   end
    #   false
    # end
    true
  end

  def user_has_access_to_action?(action)
    self.class.user_has_access_to_action?(current_user, action, self)
  end

  def login_from_session
    User.unscoped.find(session['user_id'])
  rescue StandardError
    nil
  end

  def login_from_cookie
    if !cookies[:session_token].blank? && user = User.find_by_session_token(cookies[:session_token]) # don't find by empty value
      user.remember_me
      set_session_cookie(user)
      user
    end
  end

  def login_from_http
    if [Mime[:xml], Mime[:json]].include?(request.format)
      authenticate_with_http_basic do |user_name, password|
        User.authenticate(user_name, password)
      end
    end
  end

  def set_session_cookie(user = current_user)
    cookies[:session_token] = { value: user.session_token, expires: (Time.now + (TrustyCms::Config['session_timeout'].to_i / 86400).days).utc }
  end

  module ClassMethods
    def login_required?
      filter_chain.any? { |f| f.method == :authenticate || f.method == :authorize }
    end

    def login_required
      unless login_required?
        prepend_before_action :authenticate, :authorize
      end
    end

    def only_allow_access_to(*args)
      options = {}
      options = args.pop.dup if args.last.is_a?(Hash)
      options.symbolize_keys!
      actions = args.map { |a| a.to_s.intern }
      actions.each do |action|
        controller_permissions[action] = options
      end
    end

    def controller_permissions
      @controller_permissions ||= Hash.new { |h, k| h[k.to_s.intern] = Hash.new }
    end

    def user_has_access_to_action?(user, action, instance = new)
      permissions = controller_permissions[action.to_s.intern]
      if allowed_roles = permissions[:when]
        allowed_roles = [allowed_roles].flatten
        user.present? ? allowed_roles.any? { |role| user.role?(role) } : false
      elsif condition_method = permissions[:if]
        instance.send(condition_method)
      else
        true
      end
    end
  end
end
