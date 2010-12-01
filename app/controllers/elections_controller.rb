class ElectionsController < ApplicationController
  before_filter :require_user
  before_filter :initialize_context
  before_filter :initialize_index, :only => [ :index ]
  before_filter :new_election_from_params, :only => [ :new, :create ]
  filter_access_to :new, :create, :edit, :update, :destroy, :show, :attribute_check => true

  # GET /elections
  # GET /elections.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @elections }
    end
  end

  # GET /elections/my
  # GET /elections/my.xml
  def my
    @elections = current_user.elections.allowed

    respond_to do |format|
      if @elections.size == 1
        format.html { redirect_to new_election_ballot_url( @elections.first ) }
      else
        format.html # index.html.erb
      end
      format.xml { render :xml => @elections }
    end
  end

  # GET /elections/1
  # GET /elections/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @election }
    end
  end

  # GET /elections/new
  # GET /elections/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @election }
    end
  end

  # GET /elections/1/edit
  def edit
  end

  # POST /elections
  # POST /elections.xml
  def create
    respond_to do |format|
      if @election.save
        flash[:notice] = 'Election was successfully created.'
        format.html { redirect_to(@election) }
        format.xml  { render :xml => @election, :status => :created, :location => @election }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @election.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /elections/1
  # PUT /elections/1.xml
  def update
    respond_to do |format|
      if @election.update_attributes(params[:election])
        flash[:notice] = 'Election was successfully updated.'
        format.html { redirect_to(@election) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @election.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /elections/1
  # DELETE /elections/1.xml
  def destroy
    @election.destroy

    respond_to do |format|
      format.html { redirect_to(elections_url) }
      format.xml  { head :ok }
    end
  end

  private

  def initialize_context
    @election = Election.find params[:id] if params[:id]
  end

  def initialize_index
    @elections = Election
    @search = @elections.with_permissions_to(:show).search( params[:search] )
    @elections = @search.paginate( :page => params[:page] )
  end

  def new_election_from_params
    @election = Election.new( params[:election] )
  end

end

