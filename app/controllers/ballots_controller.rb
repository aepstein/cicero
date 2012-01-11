class BallotsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_ballot_from_params, :only => [ :new, :create, :preview, :confirm ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :confirm,
    :preview, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :tabulate, @election ) if @election
    permitted_to!( :tabulate, @race ) if @race
    permitted_to!( :tabulate, @user ) if @user
    true
  end

  # GET /elections/:election_id/ballots
  # GET /elections/:election_id/ballots.xml
  # GET /races/:race_id/ballots.blt
  def index
    @search = params[:search] || Hash.new
    @search.each do |k,v|
      if !v.blank? && Ballot::SEARCHABLE.include?( k.to_sym )
        @ballots = @ballots.send k, v
      end
    end

    respond_to do |format|
      if @race
        format.blt { send_data @race.to_blt, :type => 'text/blt', :filename => @race.to_s(:file) }
      end
      format.html # index.html.erb
      format.xml  { render :xml => @ballots }
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
        UserMailer.ballot_verification( @ballot ).deliver
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
    @ballot.destroy

    respond_to do |format|
      format.html { redirect_to election_ballots_url @ballot.election }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @ballot = Ballot.find params[:id] if params[:id]
    @election = Election.find params[:election_id] if params[:election_id]
    @race = Race.find params[:race_id] if params[:race_id]
    @user = User.find params[:user_id] if params[:user_id]
    @context = @election || @race || @user
  end

  def initialize_index
    @ballots = @context.ballots.with_permissions_to(:show).page(params[:page])
  end

  def new_ballot_from_params
    @ballot = @election.ballots.build params[:ballot]
    @ballot.user = ( @user ? @user : current_user )
  end

end

