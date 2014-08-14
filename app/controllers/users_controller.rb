class UsersController < ApplicationController
  before_filter :require_user
  expose(:roll) { Roll.find params[:roll_id] if params[:roll_id] }
  expose :q do
    params[:q] ||
      ( params[:term] ? { name_contains: params[:term] } : Hash.new )
  end
  expose(:q_scope) do
    scope = roll.users if roll
    scope ||= User.all
    q.each do |k,v|
      if !v.blank? && User::SEARCHABLE.include?( k.to_sym )
        scope = scope.send k, v
      end
    end
    scope
  end
  expose(:users) { q_scope.with_permissions_to(:show).page(params[:page]) }
  expose(:user) do
    if params[:id]
      User.find params[:id]
    else
      out = User.new
      out.assign_attributes user_attributes if params[:user]
      out
    end
  end
  expose(:user_attributes) do
    attributes = [ :first_name, :last_name, :email, :password,
    :password_confirmation ]
    attributes += [ :net_id, :admin, { roll_ids: [] } ] if current_user.admin?
    params.require(:user).permit( *attributes )
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    attribute_check: true, load_method: :user
  filter_access_to :index do
    permitted_to! :show, roll if roll
    permitted_to! :index, :users
  end
  filter_access_to :bulk, :bulk_create, require: :create

  # GET /rolls/:roll_id/users/new/bulk
  def bulk; end

  # POST /users
  # POST /users.xml
  def create
    respond_to do |format|
      if user.save
        format.html { redirect_to(user, flash: { success: 'User created.' }) }
        format.xml  { render xml: user, status: :created, location: user }
      else
        format.html { render action: "new" }
        format.xml  { render xml: user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    respond_to do |format|
      if user.update_attributes( params[:user] ? user_attributes : {} )
        format.html { redirect_to(user, flash: { success: 'User updated.' }) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url, flash: { success: 'User destroyed.' }) }
      format.xml  { head :ok }
    end
  end

  # POST /rolls/:roll_id/users/bulk_create
  def bulk_create
    respond_to do |format|
      flash[:success] = "Processed new voters"
      # Add from form field
      unless params[:users].nil? || params[:users].empty?
        import_results = roll.users.import_from_string( params[:users] )
      end
      # Add from file
      unless params[:users_file].is_a?( String ) || params[:users_file].nil?
        import_results = roll.users.import_from_file( params[:users_file] )
      end
      import_results ||= [0,0]
      flash[:success] += ": #{import_results.first} new voters and #{import_results.last} new users."
      format.html { redirect_to bulk_new_roll_user_url roll }
      format.xml { head :ok }
    end
  end
end

