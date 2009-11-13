class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  # GET /rolls/:roll_id/users
  # GET /rolls/:roll_id/users
  def index
    @search = params[:search]
    @users = User.search(@search,params[:page])

    respond_to do |format|
      format.html # index.html.erb
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
    @roll = Roll.find(:roll_id)
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

    params[:user][:roll_ids] ||= Array.new

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
    @roll = Election.find(params[:election_id]).rolls.find(params[:roll_id])
    raise AuthorizationError unless @roll.may_user?(current_user, :update)

    respond_to do |format|
      flash[:notice] = "Added voters.\n"
      # Add from form field
      unless params[:users].nil? || params[:users].empty?
        import_results = @roll.import_users_from_csv_string( params[:users] )
        flash[:notice] += "Submitted form field contained #{import_results} new voters.\n"
      end
      # Add from file
      unless params[:users_file].is_a?( String )
        import_results = @roll.import_users_from_csv_file( params[:users_file] )
        flash[:notice] += "Submitted file contained #{import_results} new voters."
      end
      format.html { redirect_to( election_roll_url(@roll.election, @roll) ) }
      format.xml { head :ok }
    end
  end
end

