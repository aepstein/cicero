class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator

  protected

  def permission_denied
    flash[:error] = "You are not allowed to perform the requested action."
    redirect_to home_url
  end

end

