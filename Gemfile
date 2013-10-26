source 'http://ruby.taobao.org'

gem 'pry'
gem 'rails', '3.2.6'
gem 'mysql2'

#必须写在这里，不能写在group test中，否则spec中找不到
#gem 'factory_girl_rails'

gem 'sqlite3' # for export data to sqlite3 db

# bootstrap ui
# gem 'anjlab-bootstrap-rails', :require => 'bootstrap-rails', :git => 'git://github.com/anjlab/bootstrap-rails.git'
# gem 'bootstrap_helper'
# 分页
#gem 'bootstrap-will_paginate', '0.0.3' #rails 3.2.3下有错

# user auth
gem 'devise'
# authorize
gem 'cancan'

gem 'daemons'
gem 'rack', '1.4.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'

  gem 'uglifier', '>= 1.0.3'
end

gem 'coffee-rails', '~> 3.2.1'
gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

gem 'json'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

#-----------------------------------------------
gem 'mail'
gem 'resque_mailer'
gem 'paperclip'

gem 'will_paginate'
#gem 'shorturl'
gem 'RedCloth'
gem 'coderay'

#异步发送电子邮件
gem 'actionmailer'
gem 'ar_mailer_rails3', '>= 2.1.12'

#memcached
gem 'dalli'
#gem 'thinking-sphinx', :require => 'thinking_sphinx'
gem 'redis'

#一些feedzirra用到的gem
gem 'curb'
gem 'nokogiri'
gem 'sax-machine'
gem 'loofah'
gem 'feedzirra'

gem 'simple_form'
gem 'haml'
gem 'haml-rails'
gem 'rails3-generators'

gem 'acts-as-taggable-on'     #tag标签支持
gem 'uuidtools', '>= 2.1.1'   #支持生成MD5,SHA等uid
gem 'simple-rss'               
gem 'later_dude', '>= 0.3.1'  #laterDude is a small calendar helper with i18n support. 

gem 'wirble'  #支持在irb及rails console中自动补齐及支持上下键调出历史命令(配合~/.irbrc使用)

gem 'rack-test'

gem 'faker'
#国际化
gem 'i18n'
gem "rails-i18n","0.1.8"
gem 'populator'
gem 'in_place_editing'

gem 'active_scaffold', '3.2.15'#for rails3.2

gem 'dynamic_form'

# generate detection report
gem 'zipruby'
gem 'fastimage'

# support Microsoft Word docx file( 以下两个gem, 在rubygems.org上是找不到的, 所以要指定git地址
# gem "zipruby-compat", :git => "git@github.com:jawspeak/zipruby-compatibility-with-rubyzip-fork.git", :tag => "v0.3.7"
# gem 'docx_templater', :git => "git@github.com:jawspeak/ruby-docx-templater.git"

group :test, :development do
  gem 'rspec'
  gem 'autotest'
  gem 'autotest-rails'
  gem 'autotest-growl'

  gem "rspec-rails", "~> 2.6"

  gem "email_spec"

  gem 'spork-rails'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara'
end

# Use unicorn as the app server
group :production do
  gem 'unicorn'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-unicorn'
  gem 'capistrano-file_db'
  gem 'rvm-capistrano'
end


gem 'rubyzip', '< 1.0.0'
# gem 'spreadsheet'
gem 'roo'
gem 'easy_captcha'
gem 'doorkeeper'
# gem 'doorkeeper', :git => 'git://github.com/applicake/doorkeeper.git'
gem 'sidekiq'
gem 'slim'
gem 'sinatra', :require => false
gem 'redis-rails'
gem 'hiredis'
gem 'zeus'
gem 'ZenTest', '~> 4.9.3'
