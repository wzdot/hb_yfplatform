#coding: utf-8
class PasswordsController < Devise::PasswordsController
	layout 'forget'

	def create
		@resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(@resource)
    	content = "本次密码重置的短信认证码为：#{@resource.password_sms_code}，有效期1小时。"
    	User.delay.send_sms(@resource.mobile, content) if User.use_sms_code?
    	flash[:notice] = I18n.t 'devise.passwords.send_instructions'
    end
	end

	def update
		@resource = resource_class.reset_password_by_token(resource_params)
		sign_in(@resource) if @resource.errors.empty?
	end
end
