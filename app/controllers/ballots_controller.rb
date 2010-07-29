class BallotsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_ballot_from_params, :only => [ :new, :create, :preview, :confirm ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :confirm,
    :preview, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @election ) if @election
    permitted_to!( :show, @race ) if @race
    permitted_to!( :show, @user ) if @user
  end

  # GET /elections/:election_id/ballots
  # GET /elections/:election_id/ballots.xml
  # GET /races/:race_id/ballots.blt
  def index
    @search = @ballots.searchlogic( params[:search] )
    @ballots = @search.paginate( :page => params[:page] )

    respond_to do |format|
      if @election
        format.html # index.html.erb
        format.xml  { render :xml => @ballots }
      else
        format.blt { send_data @race.to_blt, :type => 'text/blt', :filename => @race.to_s(:file) }
      end
    end
  end

  # GET /ballots/:id/show
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /elections/:election_id/ballots/new
  # GET /elections/:election_id/ballots/new.xml
  def preview
    @ballot.sections.populate

    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end

  # GET /elections/:election_id/ballots/new
  # GET /elections/:election_id/ballots/new.xml
  def new
    @ballot.sections.populate

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ballot }
    end
  end

  # GET /elections/:election_id/ballots/new/confirm
  def confirm
    respond_to do |format|
      if @ballot.valid?
        @ballot.sections.each { |section| section.freeze && section.votes.each { |vote| vote.freeze } }
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
    respond_to do |format|
      if @ballot.confirmation && @ballot.save
        flash[:notice] = 'Ballot was successfully created.'
        UserMailer.deliver_ballot_verification @ballot
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
    puts '***destroying'
    @ballot.destroy

    respond_to do |format|
      format.html { puts '***redirecting'; redirect_to election_ballots_url(@ballot.election) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @ballot = Ballot.find params[:id] if params[:id]
    @election = Election.find params[:election_id] if params[:election_id]
    @race = Race.find params[:race_id] if params[:race_id]
    @user = User.find params[:user_id] if params[:user_id]
  end

  def initialize_index
    if @election
      @ballots = Ballot.scoped( :conditions => { :election_id => @election.id } ) if @election
    elsif @race
      @ballots = Ballot.scoped( :conditions => { :race_id => @race.id } ) if @race
    elsif @user
      @ballots = Ballot.scoped( :conditions => { :user_id => @user.id } ) if @user
    end
    @ballots = @ballots.with_permissions_to(:show)
  end

  def new_ballot_from_params
    @ballot = @election.ballots.build params[:ballot]
    @ballot.user = ( @user ? @user : current_user )
  end

end

