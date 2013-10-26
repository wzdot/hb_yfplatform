#coding: utf-8
require 'fiber'

class SessionsController < Devise::SessionsController
  layout 'simple'

  def new
    session[:return_to] = request.query_string unless request.query_string.blank?
    super
  end

  def create

  end

  def automatic
    email = Base64.decode64(params[:email])
    user = User.find_by_email(email)
    sign_in(user)
    redirect_to '/'
  end

  def timeout_redirect
    
  end

  def page_show_extra
		render :json => { :use_captcha => use_captcha?, :use_sms_code => User.use_sms_code?}
  end

  def sms_code
  	user = User.find_by_email(params[:email])
    render :json => {:success => -1, :desc => '用户信息不存在'} and return if user.nil?
    render :json => {:success => 99, :desc => '认证码请求过于频繁'} and return if user.ask_smscode_fast?
    if user.generate_sms_code?
      content = "本次登录短信认证码为：#{user.sms_code}，有效期30分钟。"
      User.delay.send_sms(user.mobile, content)
      render :json => {:success => 0, :desc => user.sms_code}
    else
      render :json => {:success => 1, :desc => '认证码生成失败'}
    end
  end

  def use_captcha?(limit = 3)
    User.login_with_captcha? && login_fail_times >= limit
  end

  def login_fail_times
    return 0 if session[:login_fail_count].nil?
    session[:login_fail_count].to_i
  end
end
