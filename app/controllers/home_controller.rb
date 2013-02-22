class HomeController < ApplicationController
  before_filter :require_user
  expose(:elections) { current_user.elections.allowed.ordered }

  # GET /home
  def home
    respond_to do |format|
      format.html do
        if elections.length == 1
          redirect_to new_election_ballot_path elections.first
        else
          render action: 'home'
        end
      end
    end
  end
end

