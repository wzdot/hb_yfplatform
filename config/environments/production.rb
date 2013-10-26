# -*- coding: utf-8 -*-
Yfplatform::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  # 暂时不生成md5指纹方式的静态文件名.(因为在多台服务器上,生成的md5指纹不一样)
  config.assets.digest = false #true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( page-index.css page-login.css page-analyse.css page-data-dictionary.css page-composite.css define_dashboard.js page-analyse.js page-admin.css )
  config.assets.precompile = ['*.css', '*.scss', '*.css.erb', '*.scss.erb', '*.js', '*.coffee', '*.jpg', '*.png', '*.gif', '*.jpeg', '*.bmp']
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.cache_store = :dalli_store, config.dalli_store_servers, config.dalli_store_options
  #config.action_controller.cache_store = :redis_store, {path: '/opt/local/redis/redis.sock', driver: :hiredis, expires_in: 30.minutes}
  config.action_controller.cache_store = :redis_store, config.redis_store_servers

  config.action_mailer.default_url_options = { :host => 'test.greatms.com' }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
     :address => "smtp.qq.com",
     :port => 25,
     :domain => "qq.com",
     :authentication => :login,
     :user_name => "yf-manager@qq.com", #你的邮箱 yf-manager@qq.com
     :password => "yf-123456" #你的密码 yf-123456
   }
end
