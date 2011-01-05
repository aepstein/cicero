class UsersController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_user_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :bulk, :bulk_create do
    permitted_to! :create
  end

  # GET /users
  # GET /users.xml
  # GET /rolls/:roll_id/users
  # GET /rolls/:roll_id/users
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json # index.json.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /rolls/:roll_id/users/new/bulk
  def bulk
    respond_to do |format|
      format.html # bulk.html.erb
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.xml
  def create
    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    params[:user][:roll_ids] ||= Array.new if params[:user]

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # POST /rolls/:roll_id/users/bulk_create
  def bulk_create
    respond_to do |format|
      flash[:notice] = "Processed new voters"
      # Add from form field
      unless params[:users].nil? || params[:users].empty?
        import_results = @roll.users.import_from_string( params[:users] )
      end
      # Add from file
      unless params[:users_file].is_a?( String ) || params[:users_file].nil?
        import_results = @roll.users.import_from_file( params[:users_file] )
      end
      import_results ||= [0,0]
      flash[:notice] += ": #{import_results.first} new voters and #{import_results.last} new users."
      format.html { redirect_to @roll }
      format.xml { head :ok }
    end
  end

  private

  def initialize_context
    @roll = Roll.find params[:roll_id] if params[:roll_id]
    @user = User.find params[:id] if params[:id]
  end

  def initialize_index
    @users = @roll.users if @roll
    @users ||= User
    @search = @users.with_permissions_to(:show).search( params[:search] )
    @users = @search.paginate( :page => params[:page] )
  end

  def new_user_from_params
    @user = User.new( params[:user] )
  end

end

