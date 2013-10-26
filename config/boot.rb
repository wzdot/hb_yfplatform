# -*- coding: utf-8 -*-
require 'rubygems'

#避免Psych::SyntaxError错误解析旧的yml文件
require 'yaml'
YAML::ENGINE.yamler = 'syck'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
