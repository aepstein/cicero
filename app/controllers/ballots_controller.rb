class BallotsController < ApplicationController
  # GET /elections/:election_id/ballots
  # GET /elections/:election_id/ballots.xml
  # GET /races/:race_id/ballots
  # GET /races/:race_id/ballots.xml
  # GET /races/:race_id/ballots.blt
  def index
    @election = Election.find(params[:election_id]) if params[:election_id]
    @race = Election.find(params[:race_id]) if params[:race_id]
    raise AuthorizationError unless current_user.admin?
    @ballots = @election.ballots

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ballots }
      format.blt # index.blt.erb
    end
  end

  # GET /ballots/:id/show
  def show
    @ballot = Ballot.find(params[:id])
    raise AuthorizationError unless @ballot.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /elections/:election_id/ballots/new
  # GET /elections/:election_id/ballots/new.xml
  def new
    @ballot = Election.find(params[:election_id]).ballots.build
    @ballot.user = current_user
    raise AuthorizationError unless @ballot.may_user?(current_user,:create)
    @ballot.initialize_options

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ballot }
    end
  end

  # GET /elections/:election_id/ballots/new/confirm
  def confirm
    @ballot = Election.find(params[:election_id]).ballots.build(params[:ballot])
    @ballot.user = current_user
    raise AuthorizationError unless @ballot.may_user?(current_user,:update)

    respond_to do |format|
      if @ballot.valid?
        @ballot.freeze
        format.html # confirm.html.erb
      else
        @ballot.initialize_options
        format.html { render :action => 'new' }
      end
    end
  end

  # POST /elections/:election_id/ballots
  # POST /elections/:election_id/ballots.xml
  def create
    @ballot = Election.find(params[:election_id]).ballots.build(params[:ballot])
    @ballot.user = current_user
    raise AuthorizationError unless @ballot.may_user?(current_user,:create)

    respond_to do |format|
      if @ballot.confirmation && @ballot.save
        flash[:notice] = 'Ballot was successfully created.'
        format.html { redirect_to @ballot }
        format.xml  { render :xml => @ballot, :status => :created, :location => @ballot }
      else
        @ballot.initialize_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @ballot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ballots/:id
  # DELETE /ballots/:id.xml
  def destroy
    @ballot = Ballot.find(params[:id])
    raise AuthorizationError unless @ballot.may_user?(current_user,:delete)
    @ballot.destroy

    respond_to do |format|
      format.html { redirect_to( election_ballots_url(@ballot.election) ) }
      format.xml  { head :ok }
    end
  end

  # GET /elections/:election_id/ballots/my
  # No XML support
  # Redirect user to own ballot and create ballot for user if one does not already exist
  def my
    election = Election.find(params[:election_id])
    @ballot = election.ballots.for_user( current_user )
    respond_to do |format|
      if @ballot.nil?
        @ballot = election.ballots.build
        @ballot.user = current_user
        @ballot.save
        format.html { redirect_to( edit_election_ballot_url(@ballot.election, @ballot) ) }
      else
        format.html { redirect_to( edit_election_ballot_url(@ballot.election, @ballot) ) }
      end
    end
  end
end

