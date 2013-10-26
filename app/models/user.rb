# -*- coding: utf-8 -*-
require 'net/http'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable #, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :mobile, :sms_code, :sms_code_expired_at, :password_sms_code, :reset_password_token, :reset_password_sent_at, :level, :item_id, :parent_id

  # ??? 什么作用?
  before_create :ensure_authentication_token
  alias_attribute :private_token, :authentication_token

  # validates_presence_of :name, :password_confirmation
  # validates_presence_of :mobile, :if => :mobile_allow_nil?

  # def mobile_allow_nil?
  #   mobile.present?
  # end

  scope :admins, where(:admin =>  true)
  scope :blocked, where(:blocked =>  true)
  scope :active, where(:blocked =>  false)

  def self.filter filter_name
    case filter_name
    when "admins"; self.admins
    when "blocked"; self.blocked
    else
      self.active
    end
  end

  def admin?
    admin
  end

  def identifier
    email.gsub /[@.]/, "_"
  end

  def is_admin?
    admin
  end

  def manager?
    # 暂时将第二个用户配置为权限管理者
    self.id == 2
  end

  def has_role?( role )
    case role
      when :admin then admin?
      when :manager then manager?
      when :member then true
      else false
    end
  end


  def self.generate_random_password
    (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
  end

  def first_name
    name.split(" ").first unless name.blank?
  end

  # set blocked attribute to true
  def block
    self.blocked = true
    save
  end

  def timeout_in
    1.hours
  end

  def self.login_fail_count
    3
  end

  def self.login_with_captcha?
    true
  end

  def self.use_sms_code?
    false
  end

  def generate_reset_password_token
    self.password_sms_code = rand(100000..999999)
    super
  end

  def ask_smscode_fast?(timeout = 30.minutes, interval = 1.minutes)
    return false if sms_code_expired_at.blank?
    sms_created_at = sms_code_expired_at - timeout
    Time.now - sms_created_at < interval
  end

  def generate_sms_code?(timeout = 30.minutes)
    code = rand(100000..999999)
    @sms_code = code
    update_attributes(:sms_code => code, :sms_code_expired_at => Time.now + timeout)
  end

  def sms_code_expired?
    sms_code_expired_at < Time.now
  end

  def expired_sms_code!
    update_attributes(:sms_code_expired_at => Time.now)
  end

  def clear_reset_password_token
    self.password_sms_code = nil
    super
  end

  def self.reset_password_by_token(attributes={})
    recoverable = find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])
    if recoverable.persisted?
      if recoverable.reset_password_period_valid?
        if use_sms_code?
          if recoverable.password_sms_code != attributes[:password_sms_code]
            recoverable.errors.add(:password_sms_code, :sms_code_mismatch)
          else
            recoverable.reset_password!(attributes[:password], attributes[:password_confirmation])
          end
        else
          recoverable.reset_password!(attributes[:password], attributes[:password_confirmation])
        end
      else
        recoverable.errors.add(:reset_password_token, :expired)
      end
    end
    recoverable
  end

  class << self
    def api_url
      'http://www.tui3.com'
    end

    def app_key
      '5becf5ec8c51836c1fe102430d2b7dff'
    end

    def format
      'json'      # 支持json和xml两种格式
    end

    def product_id
      2           # 1:推信 | 2:推信DIY
    end

    def send_sms(mobiles, content, encode = :utf8)
      uri = "/api/send/?k=#{app_key}&r=#{format}&p=#{product_id}&t=#{mobiles}"
      if encode == :utf8
        uri << "&c=#{content}"
      end
      if encode == :gbk
        uri << "&cn=#{content}"
      end
      url = URI.parse(api_url)
      Net::HTTP.start(url.host, url.port) {|http|
        response = http.get(uri)
        p response.body
      }
    end
  end
end
