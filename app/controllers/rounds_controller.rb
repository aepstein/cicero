class RoundsController < ApplicationController
  # GET /races/:race_id/rounds
  # GET /races/:race_id/rounds.xml
  def index
    @race = Election.find(params[:election_id]).races.find(params[:race_id])
    @rounds = @race.rounds

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rounds }
    end
  end

  # GET /rounds/1
  # GET /rounds/1.xml
  def show
    @round = Election.find(params[:election_id]).races.find(params[:race_id]).rounds.find(params[:id])
    raise AuthorizationError unless @round.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @round }
    end
  end

  # GET /races/:race_id/rounds/new
  # GET /races/:race_id/rounds/new.xml
  def new
    @round = Race.find(params[:race_id]).rounds.build
    raise AuthorizationError unless @round.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @round }
    end
  end

  # GET /rounds/1/edit
  def edit
    @round = Round.find(params[:id])
    raise AuthorizationError unless @round.may_user?(current_user,:update)
  end

  # POST /races/:race_id/rounds
  # POST /races/:race_id/rounds.xml
  def create
    @round = Round.new(params[:round])
    raise AuthorizationError unless @round.may_user?(current_user,:create)

    respond_to do |format|
      if @round.save
        flash[:notice] = 'Round was successfully created.'
        format.html { redirect_to(@round) }
        format.xml  { render :xml => @round, :status => :created, :location => @round }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @round.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rounds/1
  # PUT /rounds/1.xml
  def update
    @round = Round.find(params[:id])
    raise AuthorizationError unless @round.may_user?(current_user,:update)

    respond_to do |format|
      if @round.update_attributes(params[:round])
        flash[:notice] = 'Round was successfully updated.'
        format.html { redirect_to(@round) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @round.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rounds/1
  # DELETE /rounds/1.xml
  def destroy
    @round = Round.find(params[:id])
    raise AuthorizationError unless @round.may_user?(current_user,:delete)
    @round.destroy

    respond_to do |format|
      format.html { redirect_to(rounds_url) }
      format.xml  { head :ok }
    end
  end
end

