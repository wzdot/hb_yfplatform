class RegistrationsController < Devise::RegistrationsController
  before_filter :auth_admin, :only => [ :new, :create ]

  layout 'simple'
  private
  def auth_admin
  end
end
