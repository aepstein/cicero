class CandidatesController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_candidate_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @race ) if @race
  end

  # GET /races/:race_id/candidates
  # GET /races/:race_id/candidates.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @candidates }
    end
  end

  # GET /candidates/:id
  # GET /candidates/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @candidate }
    end
  end

  # GET /candidates/:id/popup
  def popup
    respond_to do |format|
      format.html { render :layout => false } # popup.html.erb
    end
  end

  # GET /races/:race_id/candidates/new
  # GET /races/:race_id/candidates/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @candidate }
    end
  end

  # GET /candidates/1/edit
  def edit
  end

  # POST /races/:race_id/candidates
  # POST /races/:race_id/candidates.xml
  def create
   respond_to do |format|
      if @candidate.save
        flash[:notice] = "Candidate was successfully created."
        format.html { redirect_to @candidate }
        format.xml  { render :xml => @candidate, :status => :created, :location => @candidate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @candidate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /candidates/1
  # PUT /candidates/1.xml
  def update
    respond_to do |format|
      if @candidate.update_attributes(params[:candidate])
        flash[:notice] = 'Candidate was successfully updated.'
        format.html { redirect_to @candidate }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @candidate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /candidates/1
  # DELETE /candidates/1.xml
  def destroy
    @candidate.destroy

    respond_to do |format|
      format.html { redirect_to race_candidates_url( @candidate.race ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @race = Race.find params[:race_id] if params[:race_id]
    @candidate = Candidate.find params[:id] if params[:id]
  end

  def initialize_index
    @candidates = Candidate.scoped :conditions => { :race_id => @race.id }
    @search = @candidates.searchlogic( params[:search] )
    @candidates = @search.paginate( :page => params[:page] )
  end

  def new_candidate_from_params
    @candidate = @race.candidates.build( params[:candidate] )
  end

end

