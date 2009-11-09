class RollsController < ApplicationController
  # GET /elections/:id/rolls
  # GET /elections/:id/rolls.xml
  def index
    @election = Election.find(params[:election_id])
    @rolls = @election.rolls

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rolls }
    end
  end

  # GET /rolls/:id
  # GET /rolls/:id.xml
  def show
    @roll = Roll.find(params[:id])
    raise AuthorizationError unless @roll.may_user?(current_user, :show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @roll }
    end
  end

  # GET /elections/:id/rolls/new
  # GET /elections/:id/rolls/new.xml
  def new
    @roll = Election.find(params[:election_id]).rolls.build
    raise AuthorizationError unless @roll.may_user?(current_user, :create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @roll }
    end
  end

  # GET /rolls/1/edit
  def edit
    @roll = Roll.find(params[:id])
    raise AuthorizationError unless @roll.may_user?(current_user, :update)
  end

  # POST /elections/:election_id/rolls
  # POST /elections/:election_id/rolls.xml
  def create
    @roll = Election.find(params[:election_id]).rolls.build(params[:roll])
    raise AuthorizationError unless @roll.may_user?(current_user, :create)

    respond_to do |format|
      if @roll.save
        flash[:notice] = 'Roll was successfully created.'
        format.html { redirect_to @roll }
        format.xml  { render :xml => @roll, :status => :created, :location => @roll }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @roll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rolls/1
  # PUT /rolls/1.xml
  def update
    @roll = Roll.find(params[:id])
    raise AuthorizationError unless @roll.may_user?(current_user, :update)

    respond_to do |format|
      if @roll.update_attributes(params[:roll])
        flash[:notice] = "Roll #{@roll.name} was successfully updated."
        format.html { redirect_to( election_roll_url( @roll.election, @roll) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @roll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rolls/1
  # DELETE /rolls/1.xml
  def destroy
    @roll = Roll.find(params[:id])
    raise AuthorizationError unless @roll.may_user?(current_user, :delete)

    @roll.destroy

    respond_to do |format|
      format.html { redirect_to( election_rolls_url(@roll.election) ) }
      format.xml  { head :ok }
    end
  end
end

