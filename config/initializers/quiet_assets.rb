# -*- coding: utf-8 -*-
# 这段代码让这样的log不显示
# Started GET "/assets/jquery-ui.js?body=1" for 127.0.0.1 at 2012-03-30 11:52:05 +0800

Rails::Rack::Logger.class_eval do 
  def call_with_quiet_assets(env)
    previous_level = Rails.logger.level
    Rails.logger.level = Logger::ERROR if env['PATH_INFO'].index("/assets/") == 0 
    call_without_quiet_assets(env).tap do
      Rails.logger.level = previous_level
    end 
  end 
  alias_method_chain :call, :quiet_assets 
end
