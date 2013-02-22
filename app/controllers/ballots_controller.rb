class BallotsController < ApplicationController
  before_filter :require_user
  before_filter :populate_sections, only: [ :new, :preview ]
  expose( :election ) { Election.find( params[:election_id] ) if params[:election_id] }
  expose( :race ) { Race.find( params[:race_id] ) if params[:race_id] }
  expose( :user ) { User.find( params[:user_id] ) if params[:user_id] }
  expose( :context ) { election || race || user }
  expose( :q ) { params[:q] || Hash.new }
  expose :q_scope do
    scope = context.ballots
    q.each do |k,v|
      if !v.blank? && Ballot::SEARCHABLE.include?( k.to_sym )
        scope = scope.send k, v
      end
    end
    scope
  end
  expose :ballots do
    q_scope.with_permissions_to(:show).page(params[:page])
  end
  expose :ballot do
    if params[:id]
      Ballot.find params[:id]
    else
      election.ballots.build do |ballot|
        ballot.user = user || current_user
        ballot.assign_attributes params[:ballot]
      end
    end
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :confirm,
    :preview, load_method: :ballot, attribute_check: true
  filter_access_to :index do
    permitted_to! :show, user if user
    permitted_to! :tabulate, race if race
    permitted_to! :tabulate, election if election
    true
  end

  # GET /elections/:election_id/ballots
  # GET /elections/:election_id/ballots.xml
  # GET /races/:race_id/ballots.blt
  def index
    respond_to do |format|
      if race
        format.blt { send_data race.to_blt, type: 'text/blt', filename: race.to_s(:file) }
      end
      format.html # index.html.erb
      format.xml  { render xml: ballots }
    end
  end

  # GET /elections/:election_id/ballots/new
  # GET /elections/:election_id/ballots/new.xml
  def preview
    respond_to do |format|
      format.html { render action: 'new' }
    end
  end

  # GET /elections/:election_id/ballots/new/confirm
  def confirm
    respond_to do |format|
      if ballot.valid?
        ballot.sections.each { |section| section.freeze && section.votes.each { |vote| vote.freeze } }
        format.html # confirm.html.erb
      else
        populate_sections
        format.html { render action: 'new' }
      end
    end
  end

  # POST /elections/:election_id/ballots
  # POST /elections/:election_id/ballots.xml
  def create
    respond_to do |format|
      if ballot.confirmation && ballot.save
        format.html { redirect_to ballot, flash: { success: 'Ballot cast.' } }
        format.xml  { render xml: ballot, status: :created, location: ballot }
      else
        ballot.sections.populate
        format.html { render action: "new" }
        format.xml  { render xml: ballot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ballots/:id
  # DELETE /ballots/:id.xml
  def destroy
    ballot.destroy

    respond_to do |format|
      format.html { redirect_to election_ballots_url ballot.election, flash: { success: 'Ballot destroyed.' } }
      format.xml  { head :ok }
    end
  end

  private

  def populate_sections; ballot.sections.populate; end

end

