class Elections::Races::BallotsController < ApplicationController
  # GET /elections/:election_id/races/:id/ballots
  # GET /elections/:election_id/races/:id/ballots.xml
  def index
    @election = Election.find(params[:election_id])
    @race = @election.races.find(params[:race_id])
    raise AuthorizationError unless current_user.admin?

    respond_to do |format|
      format.blt # index.blt.erb
    end
  end
end
