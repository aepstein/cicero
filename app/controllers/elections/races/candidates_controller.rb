class Elections::Races::CandidatesController < ApplicationController
  # GET /elections/:election_id/races/:race_id/candidates
  # GET /elections/:election_id/races/:race_id/candidates.xml
  def index
    @race = Election.find(params[:election_id]).races.find(params[:race_id])
    @candidates = @race.candidates

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @candidates }
    end
  end

  # GET /elections/:election_id/races/:race_id/candidates/:id
  # GET /elections/:election_id/races/:race_id/candidates/:id.xml
  # GET /elections/:election_id/races/:race_id/candidates/:id.jpg
  def show
    @candidate = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @candidate }
      format.jpg do
        send_file( @candidate.picture_path(params[:size] ? params[:size] : :small),
                   { :type => 'image/jpeg',
                     :disposition => 'inline' }
                 )
      end
    end
  end
  
  # GET /elections/:election_id/races/:race_id/candidates/:id/popup
  def popup
    @candidate = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:show)
    respond_to do |format|
      format.html { render :layout => false } # popup.html.erb
    end
  end

  # GET /elections/:election_id/races/:race_id/candidates/new
  # GET /elections/:election_id/races/:race_id/candidates/new.xml
  def new
    @candidate = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.build
    raise AuthorizationError unless @candidate.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @candidate }
    end
  end

  # GET /elections/:election_id/races/:race_id/candidates/1/edit
  def edit
    @candidate = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.find(params[:id])
    raise AuthorizationError unless @candidate.may_user?(current_user,:update)
  end

  # POST /elections/:election_id/races/:race_id/candidates
  # POST /elections/:election_id/races/:race_id/candidates.xml
  def create
    @candidate = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.build(params[:candidate])
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

  # PUT /elections/:election_id/races/:race_id/candidates/1
  # PUT /elections/:election_id/races/:race_id/candidates/1.xml
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

  # DELETE /elections/:election_id/races/:race_id/candidates/1
  # DELETE /elections/:election_id/races/:race_id/candidates/1.xml
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
