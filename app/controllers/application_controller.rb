# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # reset captcha code after each request for security
  # after_filter :reset_last_captcha_code!

  protect_from_forgery
  before_filter :set_locale
  before_filter :authenticate_user!, :unless => lambda { request.path =~ /\/api\/.*/ }
  doorkeeper_for :all, :if => lambda { json = request.path =~ /\/api\/.*/; @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token and json; json }
  before_filter :reject_blocked!
  before_filter :set_current_user_for_mailer
  # before_filter :session_unauthorized
  helper_method :abilities, :can?, :is_ie6?

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render "errors/not_found", :layout => "error", :status => 404
  end

  layout :layout_by_resource
 
  # 用locale参数的方式指定本地化语言
  def set_locale
    if params[ :locale ]
      I18n.locale = params[:locale] || I18n.default_locale
    else
      I18n.locale = extract_locale_from_subdomain || I18n.default_locale
    end
  end

  # 从域名中解析出locale
  # Get locale code from request subdomain (like http://it.application.local:3000)
  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    if parsed_locale
      I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale : nil
    end
  end

  protected

  def reject_blocked!
    if current_user && current_user.blocked
      sign_out current_user 
      flash[:alert] = "Your account was blocked"
      redirect_to new_user_session_path
    end
  end

  def after_sign_in_path_for resource
    if resource.is_a?(User) && resource.respond_to?(:blocked) && resource.blocked
      sign_out resource
      flash[:alert] = "Your account was blocked"
      new_user_session_path
    else
      super
    end
  end

  def session_unauthorized
    env['warden'].unauthenticated?
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def set_current_user_for_mailer
    MailerObserver.current_user = current_user
  end

  def abilities
    @abilities ||= Six.new
  end

  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end

  def authenticate_admin!
    return render_404 unless current_user.is_admin?
  end

  def access_denied!
    render "errors/access_denied", :layout => "error", :status => 404
  end

  def not_found!
    render "errors/not_found", :layout => "error", :status => 404
  end

  def render_404
    render :file => File.join(Rails.root, "public", "404"), :layout => false, :status => "404"
  end

  def no_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def render_full_content
    @full_content = true
  end

  def is_ie6?
    !!request.env['HTTP_USER_AGENT'].downcase.match(/msie\s+(6.0|7.0)/)
  end

  private
  # Overwriting the sign_out redirect path method
  # 让devise在sign out后转到root path
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end

