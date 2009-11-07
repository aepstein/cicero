class CandidatesController < ApplicationController
  # GET /races/:race_id/candidates
  # GET /races/:race_id/candidates.xml
  def index
    @race = Race.find(params[:race_id])
    @candidates = @race.candidates

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @candidates }
    end
  end

  # GET /candidates/:id
  # GET /candidates/:id.xml
  def show
    @candidate = Candidate.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @candidate }
    end
  end

  # GET /candidates/:id/popup
  def popup
    @candidate = Candidate.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:show)
    respond_to do |format|
      format.html { render :layout => false } # popup.html.erb
    end
  end

  # GET /races/:race_id/candidates/new
  # GET /races/:race_id/candidates/new.xml
  def new
    @candidate = Race.find(params[:race_id]).candidates.build
    raise AuthorizationError unless @candidate.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @candidate }
    end
  end

  # GET /candidates/1/edit
  def edit
    @candidate = Candidate.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:update)
  end

  # POST /races/:race_id/candidates
  # POST /races/:race_id/candidates.xml
  def create
    @candidate = Race.find(params[:race_id]).candidates.build(params[:candidate])
    raise AuthorizationError unless @candidate.may_user?(current_user,:create)

    respond_to do |format|
      if @candidate.save
        flash[:notice] = "Candidate #{@candidate} was successfully created."
        format.html { redirect_to( election_race_candidate_url(
          @candidate.race.election,
          @candidate.race,
          @candidate) ) }
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
    @candidate = Candidate.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:update)

    respond_to do |format|
      if @candidate.update_attributes(params[:candidate])
        flash[:notice] = 'Candidate was successfully updated.'
        format.html { redirect_to( election_race_candidate_url(
          @candidate.race.election,
          @candidate.race,
          @candidate) ) }
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
    @candidate = Candidate.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:delete)
    @candidate.destroy

    respond_to do |format|
      format.html { redirect_to(election_race_candidates_url(
        @candidate.race.election,
        @candidate.race) ) }
      format.xml  { head :ok }
    end
  end
end

