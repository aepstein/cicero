class ElectionsController < ApplicationController
  before_filter :require_user
  expose :q_scope do
    scope = current_user.elections.allowed if params[:action] == 'my'
    scope ||= Election.scoped
    scope
  end
  expose :q do
    q_scope.with_permissions_to(:show).search( params[:search] )
  end
  expose :elections do
    q.result.page( params[:page] )
  end
  expose :election
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    load_method: :election, attribute_check: true

  # GET /elections/my
  # GET /elections/my.xml
  def my
    respond_to do |format|
      if elections.size == 1
        format.html { redirect_to new_election_ballot_url( elections.first ) }
      else
        format.html # my.html.erb
      end
    end
  end

  # POST /elections
  # POST /elections.xml
  def create
    respond_to do |format|
      if election.save
        format.html { redirect_to(election, flash: { success: 'Election created.' }) }
        format.xml  { render :xml => election, :status => :created, :location => election }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => election.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /elections/1
  # PUT /elections/1.xml
  def update
    respond_to do |format|
      if election.update_attributes(params[:election])
        format.html { redirect_to(election, flash: { success: 'Election updated.' }) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => election.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /elections/1
  # DELETE /elections/1.xml
  def destroy
    election.destroy

    respond_to do |format|
      format.html { redirect_to(elections_url, flash: { success: 'Election destroyed.' }) }
      format.xml  { head :ok }
    end
  end
end

