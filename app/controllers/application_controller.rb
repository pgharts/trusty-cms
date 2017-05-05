#require_dependency 'trusty_cms'
require 'login_system'

class ApplicationController < ActionController::Base
  include LoginSystem
  # TODO: Add an ActionView::PathSet.new([paths]) for all extension view paths
  prepend_view_path("#{TRUSTY_CMS_ROOT}/app/views")

  protect_from_forgery

  before_action :set_current_user
  before_action :set_timezone
  before_action :set_user_locale
  before_action :set_javascripts_and_stylesheets
  before_action :force_utf8_params if RUBY_VERSION =~ /1\.9/
  before_action :set_standard_body_style, :only => [:new, :edit, :update, :create]
  before_action :set_mailer

  attr_accessor :trusty_config, :cache
  attr_reader :pagination_parameters
  helper_method :pagination_parameters

  def initialize
    super
    @trusty_config = TrustyCms::Config
  end

  def template_name
    case self.action_name
    when 'index'
      'index'
    when 'new','create'
      'new'
    when 'show'
      'show'
    when 'edit', 'update'
      'edit'
    when 'remove', 'destroy'
      'remove'
    else
      self.action_name
    end
  end

  private

    def set_mailer
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
    end

    def set_current_user
      UserActionObserver.instance.current_user = current_user
    end

    def set_user_locale
      I18n.locale = current_user && !current_user.locale.blank? ? current_user.locale : TrustyCms::Config['default_locale']
    end

    def set_timezone
      Time.zone = TrustyCms::Config['local.timezone'] != nil && TrustyCms::Config['local.timezone'].empty? ? Time.zone_default : TrustyCms::Config['local.timezone']
    end

    def set_javascripts_and_stylesheets
      @stylesheets ||= []
      @stylesheets.concat %w(admin/main)
      @javascripts ||= []
    end

    def set_standard_body_style
      @body_classes ||= []
      @body_classes.concat(%w(reversed))
    end

    # When using TrustyCms with Ruby 1.9, the strings that come in from forms are ASCII-8BIT encoded.
    # That causes problems, especially when using special chars and with certain DBs, like DB2
    # That's why we force the encoding of the params to UTF-8
    # That's what's happening in Rails 3, too: https://github.com/rails/rails/commit/25215d7285db10e2c04d903f251b791342e4dd6a
    #
    # See http://stackoverflow.com/questions/8268778/rails-2-3-9-encoding-of-query-parameters
    # See https://rails.lighthouseapp.com/projects/8994/tickets/4807
    # See http://jasoncodes.com/posts/ruby19-rails2-encodings (thanks for the following code, Jason!)
    def force_utf8_params
      traverse = lambda do |object, block|
        if object.kind_of?(Hash)
          object.each_value { |o| traverse.call(o, block) }
        elsif object.kind_of?(Array)
          object.each { |o| traverse.call(o, block) }
        else
          block.call(object)
        end
        object
      end
      force_encoding = lambda do |o|
        o.force_encoding(Encoding::UTF_8) if o.respond_to?(:force_encoding)
      end
      traverse.call(params, force_encoding)
    end

end
