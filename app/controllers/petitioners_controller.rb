class PetitionersController < ApplicationController
  before_filter :require_user
  expose :candidate
  expose :q_scope do
    scope = candidate.petitioners
    q = params[:q] || Hash.new
    q.each do |k,v|
      if !v.blank? && Petitioner::SEARCHABLE.include?( k.to_sym )
        scope = scope.send k, v
      end
    end
    scope
  end
  expose :petitioners do
    q_scope.page(params[:page])
  end
  expose :petitioner do
    if params[:id]
      Petitioner.find params[:id]
    else
      candidate.petitioners.build do |petitioner|
        petitioner.assign_attributes params[:petitioner]
      end
    end
  end
  filter_access_to :new, :create, :edit, :update, :destroy, :show,
    load_method: :petitioner, attribute_check: true
  filter_access_to :index, load_method: :candidate, require: :show

  # POST /candidates/:candidate_id/petitioners
  # POST /candidates/:candidate_id/petitioners.xml
  def create
    respond_to do |format|
      if petitioner.save
        format.html { redirect_to candidate_petitioners_url( petitioner.candidate ), flash: { success: 'Petitioner created.' } }
        format.xml  { render xml: petitioner, status: :created, location: petitioner }
      else
        format.html { render :action => "new" }
        format.xml  { render xml: petitioner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /petitioners/:id
  # PUT /petitioners/:id.xml
  def update
    respond_to do |format|
      if petitioner.update_attributes(params[:petitioner])
        format.html { redirect_to candidate_petitioners_url( petitioner.candidate ), flash: { success: 'Petitioner updated.' } }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render xml: petitioner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /petitioners/1
  # DELETE /petitioners/1.xml
  def destroy
    petitioner.destroy

    respond_to do |format|
      format.html { redirect_to candidate_petitioners_url( petitioner.candidate ), flash: { success: 'Petitioner destroyed.' } }
      format.xml  { head :ok }
    end
  end

  private

end

