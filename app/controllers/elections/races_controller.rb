class Elections::RacesController < ApplicationController
  # GET /elections/:election_id/races
  # GET /elections/:election_id/races.xml
  def index
    @election = Election.find(params[:election_id])
    @races = @election.races

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @races }
    end
  end

  # GET /elections/:election_id/races/:id
  # GET /elections/:election_id/races/:id.xml
  def show
    @race = Election.find(params[:election_id]).races.find(params[:id])
    raise AuthorizationError unless @race.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @race }
    end
  end

  # GET /elections/:election_id/races/new
  # GET /elections/:election_id/races/new.xml
  def new
    @race = Race.new( :election => Election.find(params[:election_id]) )
    raise AuthorizationError unless @race.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @race }
    end
  end

  # GET /elections/:election_id/races/:id/edit
  def edit
    @race = Election.find(params[:election_id]).races.find(params[:id])
    raise AuthorizationError unless @race.may_user?(current_user,:update)
  end

  # POST /elections/:election_id/races
  # POST /elections/:election_id/races.xml
  def create
    @race = Election.find(params[:election_id]).races.build(params[:race])
    raise AuthorizationError unless @race.may_user?(current_user,:create)

    respond_to do |format|
      if @race.save
        flash[:notice] = 'Race was successfully created.'
        format.html { redirect_to( election_race_url(@race.election, @race) ) }
        format.xml  { render :xml => @race, :status => :created, :location => @race }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @race.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /elections/:election_id/races/:id
  # PUT /elections/:election_id/races/:id.xml
  def update
    @race = Election.find(params[:election_id]).races.find(params[:id])
    raise AuthorizationError unless @race.may_user?(current_user,:update)

    respond_to do |format|
      if @race.update_attributes(params[:race])
        flash[:notice] = 'Race was successfully updated.'
        format.html { redirect_to( election_race_url( @race.election, @race) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @race.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /elections/:election_id/races/:id
  # DELETE /elections/:election_id/races/:id.xml
  def destroy
    @race = Election.find(params[:election_id]).races.find(params[:id])
    raise AuthorizationError unless @race.may_user?(current_user,:delete)
    @race.destroy

    respond_to do |format|
      format.html { redirect_to( election_races_url( @race.election ) ) }
      format.xml  { head :ok }
    end
  end
end
