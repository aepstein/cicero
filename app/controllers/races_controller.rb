class RacesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_race_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @election ) if @election
  end

  # GET /elections/:election_id/races
  # GET /elections/:election_id/races.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @races }
    end
  end

  # GET /races/:id
  # GET /races/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @race }
    end
  end

  # GET /elections/:election_id/races/new
  # GET /elections/:election_id/races/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @race }
    end
  end

  # GET /races/:id/edit
  def edit
  end

  # POST /elections/:election_id/races
  # POST /elections/:election_id/races.xml
  def create
    respond_to do |format|
      if @race.save
        flash[:notice] = 'Race was successfully created.'
        format.html { redirect_to @race }
        format.xml  { render :xml => @race, :status => :created, :location => @race }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @race.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /races/:id
  # PUT /races/:id.xml
  def update
    respond_to do |format|
      if @race.update_attributes(params[:race])
        flash[:notice] = 'Race was successfully updated.'
        format.html { redirect_to race_url @race }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @race.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /races/:id
  # DELETE /races/:id.xml
  def destroy
    @race.destroy

    respond_to do |format|
      format.html { redirect_to( election_races_url( @race.election ) ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @election = Election.find params[:election_id] if params[:election_id]
    @race = Race.find params[:id] if params[:id]
  end

  def initialize_index
    @races = Race.scoped :conditions => { :election_id => @election.id }
    @search = @races.searchlogic( params[:search] )
    @races = @search.paginate( :page => params[:page] )
  end

  def new_race_from_params
    @race = @election.races.build( params[:race] )
  end

end

