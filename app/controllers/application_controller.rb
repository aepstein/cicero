class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator

  protected

  def permission_denied
    flash[:error] = "You may not perform the requested action."
    redirect_to root_url
  end

end

