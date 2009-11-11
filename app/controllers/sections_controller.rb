class SectionsController < ApplicationController
  # GET /race/:race_id/sections
  # GET /race/:race_id/sections.xml
  def index
    @race = Race.find(params[:race_id])
    @sections = @race.sections

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sections }
    end
  end

end

