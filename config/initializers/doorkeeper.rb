Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid, and :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do |routes|
    # Put your resource owner authentication logic here.
    # If you want to use named routes from your app, you need to call them on the routes object.
    # For example:
    #   routes.new_user_session_path
    # Example implementation:
    #   User.find_by_id(session[:user_id]) || redirect_to(routes.new_user_session_url)
    current_user || warden.authenticate!(:scope => :user)
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  admin_authenticator do |routes|
  #   # Put your admin authentication logic here.
  #   # If you want to use named routes from your app, you need to call them on routes object, e.g., routes.new_admin_session_path
  #   # Example implementation:
  #   Admin.find_by_id(session[:admin_id]) || redirect_to(routes.new_admin_session_url)
    (current_user && current_user.admin?) || redirect_to(routes.new_user_session_url)
  end

  resource_owner_from_credentials do |routes|
    u = User.find_for_database_authentication(:email => params[:username])
    u if u && u.valid_password?(params[:password])
  end

  # Authorization Code expiration time (default 10 minutes).
  # authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  # access_token_expires_in 2.hours

  # Issue access tokens with refresh token (disabled by default)
  use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  # enable_application_owner :confirmation => false

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  default_scopes  :public
  optional_scopes :write

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for mor information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param
end
