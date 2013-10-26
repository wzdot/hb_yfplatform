class Admin::UsersController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  # before_filter :authenticate_admin!

  def index
    @admin_users = User.scoped
    @admin_users = @admin_users.filter(params[:filter])
    @admin_users = @admin_users.order("updated_at DESC").page(params[:page])
  end

  def show
    @admin_user = User.find(params[:id])
  end

  def new
    @admin_user = User.new
  end

  def edit
    @admin_user = User.find(params[:id])
  end

  def block 
    @admin_user = User.find(params[:id])

    if @admin_user.block
      redirect_to :back, alert: "Successfully blocked"
    else 
      redirect_to :back, alert: "Error occured. User was not blocked"
    end
  end

  def unblock 
    @admin_user = User.find(params[:id])

    if @admin_user.update_attribute(:blocked, false)
      redirect_to :back, alert: "Successfully unblocked"
    else 
      redirect_to :back, alert: "Error occured. User was not unblocked"
    end
  end

  def create
    admin = params[:user].delete("admin")

    @admin_user = User.new(params[:user])
    @admin_user.admin = (admin && admin.to_i > 0)

    respond_to do |format|
      if @admin_user.save
        email = params[:user][:email].strip
        # TerminalUser.delay.grant(email.slice(0, email.index('@')), params[:user][:password].strip)
        format.html { redirect_to [:admin, @admin_user], notice: 'User was successfully created.' }
        format.json { render json: @admin_user, status: :created, location: @admin_user }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_role_user
    level = params[:level]
    item_id = params[:item_id]
    parent_id = params[:parent_id]
    name = params[:name]
    email = params[:email]
    password = params[:password]
    mobile = params[:mobile]
    user = User.new
    user.level = level
    user.item_id = item_id
    user.parent_id = parent_id
    user.name = name
    user.email = email
    user.password = password
    # user.admin = true if user.parent_id = 0
    user.admin = params[:admin] == 'true' ? true : false
    render :json => {:status => user.save}
  end

  def edit_role_user
    level = params[:level]
    item_id = params[:item_id]
    parent_id = params[:parent_id]
    name = params[:name]
    email = params[:email]
    password = params[:password]
    mobile = params[:mobile]
    user = User.find_by_email(email)
    if user
      user.level = level
      user.item_id = item_id
      user.parent_id = parent_id
      user.name = name
      user.mobile = mobile
      user.password = password unless password.blank?
      user.admin = params[:admin] == 'true' ? true : false
      status = user.save
    else
      status = false
    end

    render :json => {:status => status}
  end

  def update
    admin = params[:user].delete("admin")
    @admin_user = User.find(params[:id])
    @admin_user.admin = (admin && admin.to_i > 0)

    respond_to do |format|
      if @admin_user.update_attributes(params[:user])
        unless params[:user][:password].blank?
          email = @admin_user.email
          # TerminalUser.delay.edit(email.slice(0, email.index('@')), params[:user][:password].strip)
        end
        format.html { redirect_to [:admin, @admin_user], notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @admin_user = User.find(params[:id])
    @admin_user.destroy

    respond_to do |format|
      email = @admin_user.email
      # TerminalUser.delay.revoke(email.slice(0, email.index('@')))
      format.html { redirect_to admin_users_url }
      format.json { head :ok }
    end
  end
end
