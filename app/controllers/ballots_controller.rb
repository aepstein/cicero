class BallotsController < ApplicationController
  before_filter :require_user, :only => [ :my ]

  # GET /elections/:election_id/ballots
  # GET /elections/:election_id/ballots.xml
  # GET /races/:race_id/ballots
  # GET /races/:race_id/ballots.xml
  # GET /races/:race_id/ballots.blt
  def index
    @election = Election.find(params[:election_id]) if params[:election_id]
    raise AuthorizationError unless current_user.admin?
    @ballots = @election.ballots.user_name_like( params[:search] ).paginate( :page => params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ballots }
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
    @ballot.sections.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ballot }
    end
  end

  # GET /elections/:election_id/ballots/new/confirm
  def confirm
    @ballot = Election.find(params[:election_id]).ballots.build(params[:ballot])
    @ballot.user = current_user
    raise AuthorizationError unless @ballot.may_user?(current_user,:create)

    respond_to do |format|
      if @ballot.valid?
        @ballot.sections.each { |section| section.votes.each { |vote| vote.freeze } }
        format.html # confirm.html.erb
      else
        @ballot.sections.populate
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
        @ballot.sections.populate
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

end

