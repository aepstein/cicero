class PetitionersController < ApplicationController
  before_filter :require_user
  expose :candidate
  expose( :q ) { params[:q] || Hash.new }
  expose :q_scope do
    scope = candidate.petitioners
    q.each do |k,v|
      if !v.blank? && Petitioner::SEARCHABLE.include?( k.to_sym )
        scope = scope.send k, v
      end
    end
    scope
  end
  expose :petitioners do
    q_scope.with_permissions_to(:show).page(params[:page])
  end
  expose :petitioner do
    if params[:id]
      Petitioner.find params[:id]
    else
      candidate.petitioners.build do |petitioner|
        petitioner.assign_attributes petitioner_attributes if params[:petitioner]
      end
    end
  end
  expose :petitioner_attributes do
    params.require(:petitioner).permit( :user_id, :user_name )
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
        format.html { render action: "new" }
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
end

