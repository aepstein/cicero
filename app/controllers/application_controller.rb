class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator

  private

  def permission_denied
    flash[:error] = "You are not allowed to perform the requested action."
    redirect_to profile_url
  end

end

