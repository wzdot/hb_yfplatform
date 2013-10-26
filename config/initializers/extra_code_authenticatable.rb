require 'devise/strategies/authenticatable'

module Devise
	module Strategies
		class ExtraCodeAuthenticatable < Authenticatable
			def valid?
				true
      end

			def authenticate!
				if params[:controller].to_sym == :sessions and params[:action].to_sym == :create
					if params[:user]
						hash = params[:user]
						email = hash[:email].strip if hash[:email]
						password = hash[:password].strip if hash[:password]
						smscode = hash[:smscode].strip if hash[:smscode]
						captcha = hash[:captcha].strip  if hash[:captcha]
						user = User.find_by_email(email)
						if user.nil? || !user.valid_password?(password)
							increment_login_fail_times
							fail!(:unauthorized) and return
						end
						if User.use_sms_code?
							fail!(:sms_code_expired) and return if user.sms_code_expired?
							fail!(:sms_code_unmatched) and return if user.sms_code != smscode
						end
						if use_captcha?
							fail!(:captcha_unmatched) and return if captcha.upcase != session[:captcha]
						end
						user.expired_sms_code!
						remove_login_fail_times
					end
				end
			end

			def use_captcha?(limit = User.login_fail_count)
    		User.login_with_captcha? && login_fail_times >= limit
  		end

			def increment_login_fail_times
    		count = login_fail_times + 1
    		session[:login_fail_count] = count if User.login_with_captcha?
  		end

			def remove_login_fail_times
    		session[:login_fail_count] = nil
  		end

  		private
			def login_fail_times
    		return 0 if session[:login_fail_count].nil?
    		session[:login_fail_count].to_i
  		end
		end
	end
end

Warden::Strategies.add(:extra_code_authenticatable, Devise::Strategies::ExtraCodeAuthenticatable)