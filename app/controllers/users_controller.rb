class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  # GET /rolls/:roll_id/users
  # GET /rolls/:roll_id/users
  def index
    @search = params[:search]
    if params[:roll_id]
      @roll = Roll.find(params[:roll_id])
      @users = @roll.users.name_like(@search).paginate( :page => params[:page] )
    end
    @users ||= User.name_like(@search).paginate( :page =>  params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    raise AuthorizationError unless @user.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /rolls/:roll_id/users/new/bulk
  def bulk
    @roll = Roll.find(params[:roll_id])
    raise AuthorizationError unless @roll.may_user?(current_user, :update)

    respond_to do |format|
      format.html # bulk.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_user?(current_user,:update)
  end

  # POST /users
  # POST /users.xml
  def create
    return bulk_create if params[:users] || params[:users_file]
    @user = User.new(params[:user])
    raise AuthorizationError unless @user.may_user?(current_user,:create)

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
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_user?(current_user,:update)

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
    @user = User.find(params[:id])
    raise AuthorizationError unless @user.may_user?(current_user,:delete)
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  private

  def bulk_create
    @roll = Roll.find(params[:roll_id])
    raise AuthorizationError unless @roll.may_user?(current_user, :update)

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
end

