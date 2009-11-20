class PetitionersController < ApplicationController
  # GET /candidates/:candidate_id/petitioners
  # GET /candidates/:candidate_id/petitioners.xml
  def index
    @candidate = Candidate.find(params[:candidate_id])
    raise AuthorizationError unless current_user.admin?
    @petitioners = @candidate.petitioners.user_name_like(params[:search]).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @petitioners }
    end
  end

  # GET /petitioners/:id
  # GET /petitioners/:id.xml
  def show
    @petitioner = Petitioner.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @petitioner }
    end
  end

  # GET /candidates/:candidate_id/petitioners/new
  # GET /candidates/:candidate_id/petitioners/new.xml
  def new
    @petitioner = Candidate.find(params[:candidate_id]).petitioners.build
    raise AuthorizationError unless @petitioner.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @petitioner }
    end
  end

  # GET /petitioners/1/edit
  def edit
    @petitioner = Petitioner.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:update)
  end

  # POST /candidates/:candidate_id/petitioners
  # POST /candidates/:candidate_id/petitioners.xml
  def create
    @petitioner = Candidate.find(params[:candidate_id]).petitioners.build(params[:petitioner])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:create)

    respond_to do |format|
      if @petitioner.save
        flash[:notice] = 'Petitioner was successfully created.'
        format.html { redirect_to candidate_petitioners_url( @petitioner.candidate ) }
        format.xml  { render :xml => @petitioner, :status => :created, :location => @petitioner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @petitioner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /petitioners/:id
  # PUT /petitioners/:id.xml
  def update
    @petitioner = Petitioner.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:update)

    respond_to do |format|
      if @petitioner.update_attributes(params[:petitioner])
        flash[:notice] = 'Petitioner was successfully updated.'
        format.html { redirect_to candidate_petitioners_url( @petitioner.candidate ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @petitioner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /petitioners/1
  # DELETE /petitioners/1.xml
  def destroy
    @petitioner = Petitioner.find(params[:id])
    raise AuthorizationError unless @petitioner.may_user?(current_user,:delete)
    @petitioner.destroy

    respond_to do |format|
      format.html { redirect_to candidate_petitioners_url( @petitioner.candidate ) }
      format.xml  { head :ok }
    end
  end
end

