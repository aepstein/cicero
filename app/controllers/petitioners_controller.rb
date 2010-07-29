class PetitionersController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_petitioner_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true
  filter_access_to :index do
    permitted_to!( :show, @candidate ) if @candidate
  end

  # GET /candidates/:candidate_id/petitioners
  # GET /candidates/:candidate_id/petitioners.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @petitioners }
    end
  end

  # GET /petitioners/:id
  # GET /petitioners/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @petitioner }
    end
  end

  # GET /candidates/:candidate_id/petitioners/new
  # GET /candidates/:candidate_id/petitioners/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @petitioner }
    end
  end

  # GET /petitioners/1/edit
  def edit
  end

  # POST /candidates/:candidate_id/petitioners
  # POST /candidates/:candidate_id/petitioners.xml
  def create
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
    @petitioner.destroy

    respond_to do |format|
      format.html { redirect_to candidate_petitioners_url( @petitioner.candidate ) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @candidate = Candidate.find params[:candidate_id] if params[:candidate_id]
    @petitioner = Petitioner.find params[:id] if params[:id]
  end

  def initialize_index
    @petitioners = Petitioner.scoped :conditions => { :candidate_id => @candidate.id }
    @search = @petitioners.searchlogic( params[:search] )
    @petitioners = @search.paginate( :page => params[:page] )
  end

  def new_petitioner_from_params
    @petitioner = @candidate.petitioners.build( params[:petitioner] )
  end

end

