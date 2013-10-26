class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [ :show ]

  active_scaffold do |conf|
  end
end
