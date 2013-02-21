class CandidatesController < ApplicationController
  before_filter :require_user
  expose :candidate
  filter_access_to :show, :popup, require: :show, attribute_check: true

  # GET /candidates/:id/popup
  def popup
    respond_to do |format|
      format.html { render layout: false } # popup.html.erb
    end
  end
end

