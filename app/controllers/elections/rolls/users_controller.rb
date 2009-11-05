class Elections::Rolls::UsersController < ApplicationController
  # GET /elections/:election_id/rolls/:roll_id/users
  # GET /elections/:election_id/rolls/:roll_id/users.xml
  def index
    @roll = Election.find(params[:election_id]).rolls.find(params[:roll_id])
    if params[:search]
      @users = @roll.users.find_by_net_id_or_name(params[:search])
    else
      @users = @roll.users.find(:all)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /elections/:election_id/rolls/:roll_id/users/new
  # GET /elections/:election_id/rolls/:roll_id/users/new.xml
  def new
    @user = Election.find(params[:election_id]).rolls.find(params[:roll_id]).users.build
    raise AuthorizationError unless @user.may_user?(current_user, :update)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # POST /elections/:election_id/rolls/:roll_id/users/bulk_create
  # POST /elections/:election_id/rolls/:roll_id/users/bulk_create.xml
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

  # DELETE /elections/:election_id/rolls/:roll_id/users/:id
  # DELETE /elections/:election_id/rolls/:roll_id/users/:id.xml
  def destroy
    @roll = Election.find(params[:election_id]).rolls.find(params[:roll_id])
    raise AuthorizationError unless @roll.may_user?(current_user, :update)
    
    @user = @roll.users.find(params[:id])
    @roll.users.delete(@user)

    respond_to do |format|
      format.html { redirect_to( election_roll_users_url(@roll.election, @roll) ) }
      format.xml  { head :ok }
    end
  end
end
