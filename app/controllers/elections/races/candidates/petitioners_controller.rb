class Elections::Races::Candidates::PetitionersController < ApplicationController
  # GET /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners
  # GET /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners.xml
  def index
    @candidate = Election.find(params[:election_id]).races.
                   find(params[:race_id]).candidates.find(params[:candidate_id])
    @petitioners = @candidate.petitioners
    raise AuthorizationError unless current_user.admin?

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @petitioners }
    end
  end

  # GET /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/:id
  # GET /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/:id.xml
  def show
    @petitioner = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.
                    find(params[:candidate_id]).petitioners.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @petitioner }
    end
  end

  # GET /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/new
  # GET /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/new.xml
  def new
    @petitioner = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.
                    find(params[:candidate_id]).petitioners.build
    raise AuthorizationError unless @petitioner.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @petitioner }
    end
  end

  # GET /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/1/edit
  def edit
    @petitioner = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.
                    find(params[:candidate_id]).petitioners.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:update)
  end

  # POST /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners
  # POST /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners.xml
  def create
    @petitioner = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.
                    find(params[:candidate_id]).petitioners.build(params[:petitioner])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:create)

    respond_to do |format|
      if @petitioner.save
        flash[:notice] = 'Petitioner was successfully created.'
        format.html { redirect_to( election_race_candidate_petitioners_url( 
          @petitioner.candidate.race.election,
          @petitioner.candidate.race,
          @petitioner.candidate ) ) }
        format.xml  { render :xml => @petitioner, :status => :created, :location => @petitioner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @petitioner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/:id
  # PUT /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/:id.xml
  def update
    @petitioner = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.
                    find(params[:candidate_id]).petitioners.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:update)

    respond_to do |format|
      if @petitioner.update_attributes(params[:petitioner])
        flash[:notice] = 'Petitioner was successfully updated.'
        format.html { redirect_to( election_race_candidate_petitioners_url( 
          @petitioner.candidate.race.election,
          @petitioner.candidate.race,
          @petitioner.candidate ) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @petitioner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/1
  # DELETE /elections/:election_id/races/:race_id/candidates/:candidate_id/petitioners/1.xml
  def destroy
    @petitioner = Election.find(params[:election_id]).races.find(params[:race_id]).candidates.
                    find(params[:candidate_id]).petitioners.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:delete)
    @petitioner.destroy

    respond_to do |format|
      format.html { redirect_to( election_race_candidate_petitioners_url( 
        @petitioner.candidate.race.election,
        @petitioner.candidate.race,
        @petitioner.candidate ) ) }
      format.xml  { head :ok }
    end
  end
end
