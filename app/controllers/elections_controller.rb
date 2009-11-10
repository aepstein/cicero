class ElectionsController < ApplicationController
  # GET /elections
  # GET /elections.xml
  def index
    @elections = Election.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @elections }
    end
  end

  # GET /elections/my
  # GET /elections/my.xml
  def my
    @elections = current_user.elections.current_open

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
    @election = Election.find(params[:id])
    raise AuthorizationError unless @election.may_user?(current_user,:show)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @election }
    end
  end

  # GET /elections/new
  # GET /elections/new.xml
  def new
    @election = Election.new
    raise AuthorizationError unless @election.may_user?(current_user,:create)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @election }
    end
  end

  # GET /elections/1/edit
  def edit
    @election = Election.find(params[:id])
    raise AuthorizationError unless @election.may_user?(current_user,:update)
  end

  # POST /elections
  # POST /elections.xml
  def create
    @election = Election.new(params[:election])
    raise AuthorizationError unless @election.may_user?(current_user,:create)

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
    @election = Election.find(params[:id])
    raise AuthorizationError unless @election.may_user?(current_user,:update)

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

  # POST /elections/:id/tabulate
  def tabulate
    @election = Election.find(params[:id])
    raise AuthorizationError unless @election.may_user?(current_user,:tabulate)
    if @election.tabulate
      respond_to do |format|
        flash[:notice] = 'Election results successfully tabulated'
        format.html { redirect_to(@election) }
      end
    else
      format.html { redirect_to(@election) }
    end
  end

  # DELETE /elections/1
  # DELETE /elections/1.xml
  def destroy
    @election = Election.find(params[:id])
    raise AuthorizationError unless @election.may_user?(current_user,:delete)
    @election.destroy

    respond_to do |format|
      format.html { redirect_to(elections_url) }
      format.xml  { head :ok }
    end
  end
end

