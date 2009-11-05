class AuthorizationError < StandardError
end

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :login_required
  def rescue_action(e)
    case e
    when AuthorizationError
#      head :forbidden
      respond_to do |format|
        format.html { redirect_to( :controller => '/static', :action => 'unauthorized' ) }
      end
    else
      super(e)
    end
  end
end
