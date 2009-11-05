class Elections::BallotsController < ApplicationController
  # GET /elections/:election_id/ballots
  # GET /elections/:election_id/ballots.xml
  def index
    @election = Election.find(params[:election_id])
    raise AuthorizationError unless current_user.admin?
    @ballots = @election.ballots

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ballots }
    end
  end

  # GET /elections/:election_id/ballots/:id
  # GET /elections/:election_id/ballots/:id.xml
  def show
    @ballot = Election.find(params[:election_id]).ballots.find(params[:id])
    raise AuthorizationError unless @ballot.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ballot }
    end
  end

  # GET /elections/:election_id/ballots/:id/verify
  def verify
    @ballot = Election.find(params[:election_id]).ballots.find(params[:id])
    raise AuthorizationError unless @ballot.may_user?(current_user,:verify)

    respond_to do |format|
      format.html # verify.html.erb
    end
  end

  # GET /elections/:election_id/ballots/new
  # GET /elections/:election_id/ballots/new.xml
  def new
    @ballot = Election.find(params[:election_id]).ballots
    @ballot.user = current_user
    raise AuthorizationError unless @ballot.may_user?(current_user,:create)
    @ballot.initialize_options

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ballot }
    end
  end
  
  # GET /elections/:election_id/ballots/:id/confirm_new
  def confirm_new
    @ballot = Election.find(params[:election_id]).ballots.find(params[:id])
    raise AuthorizationError unless @ballot.may_user?(current_user,:update)
    @ballot.choices=(params)
    
    respond_to do |format|
      if @ballot.valid?
        @ballot.freeze
        format.html # confirm_new.html.erb
      else
        @ballot.initialize_options
        format.html { render :action => 'edit' }
      end
    end
  end

  # GET /elections/:election_id/ballots/:id/edit
  def edit
#    @ballot = Election.find(params[:election_id]).ballots.find(params[:id])
    @ballot = Ballot.find(params[:id])
    raise AuthorizationError unless @ballot.may_user?(current_user,:update)
    @ballot.initialize_options
  end

  # POST /elections/:election_id/ballots
  # POST /elections/:election_id/ballots.xml
  def create
    @ballot = Election.find(params[:election_id]).ballots.build(params[:ballot])
    @ballot.user = current_user
    raise AuthorizationError unless @ballot.may_user?(current_user,:create)

    respond_to do |format|
      if @ballot.save
        flash[:notice] = 'Ballot was successfully created.'
        format.html { redirect_to( election_ballot_url(@ballot.election, @ballot) ) }
        format.xml  { render :xml => @ballot, :status => :created, :location => @ballot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ballot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /elections/:election_id/ballots/:id
  # PUT /elections/:election_id/ballots/:id.xml
  def update
#    @ballot = Election.find(params[:election_id]).ballots.find(params[:id])
    @ballot = Ballot.find(params[:id])
    raise AuthorizationError unless @ballot.may_user?(current_user,:update)
    @ballot.choices=(params)

    respond_to do |format|
      @ballot.cast_at = DateTime.now
      if params[:commit] =~ /^Cast/ && @ballot.save
        flash[:notice] = 'Ballot was successfully cast.'
        UserMailer.deliver_ballot_verification(@ballot) unless @ballot.user.email.nil?
        format.html { redirect_to( verify_election_ballot_url(@ballot.election, @ballot) ) }
        format.xml  { head :ok }
      else
        @ballot.initialize_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ballot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /elections/:election_id/ballots/:id
  # DELETE /elections/:election_id/ballots/:id.xml
  def destroy
    @ballot = Election.find(params[:election_id]).ballots.find(params[:id])
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
