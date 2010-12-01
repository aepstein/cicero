class RollsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_roll_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @election ) if @election
  end

  # GET /elections/:id/rolls
  # GET /elections/:id/rolls.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rolls }
    end
  end

  # GET /rolls/:id
  # GET /rolls/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @roll }
    end
  end

  # GET /elections/:id/rolls/new
  # GET /elections/:id/rolls/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @roll }
    end
  end

  # GET /rolls/1/edit
  def edit
  end

  # POST /elections/:election_id/rolls
  # POST /elections/:election_id/rolls.xml
  def create
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
    respond_to do |format|
      if @roll.update_attributes(params[:roll])
        flash[:notice] = "Roll #{@roll.name} was successfully updated."
        format.html { redirect_to roll_url @roll }
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
    @roll.destroy

    respond_to do |format|
      format.html { redirect_to( election_rolls_url(@roll.election) ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @election = Election.find params[:election_id] if params[:election_id]
    @roll = Roll.find params[:id] if params[:id]
  end

  def initialize_index
    @rolls = Roll.scoped :conditions => { :election_id => @election.id }
    @search = @rolls.search( params[:search] )
    @rolls = @search.paginate( :page => params[:page] )
  end

  def new_roll_from_params
    @roll = @election.rolls.build( params[:roll] )
  end

end

