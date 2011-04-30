class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :current_user_session
  before_filter :check_authorization

  def permission_denied
    flash[:error] = "You are not allowed to perform the requested action."
    redirect_to my_elections_url
  end

  # If user has been authenticated with single sign on credentials, logs in immediately
  def sso_net_id
    net_id = request.env['REMOTE_USER'] || request.env['HTTP_REMOTE_USER']
    return false if net_id.blank?
    net_id
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
    if @current_user && ( @current_user.net_id != sso_net_id )
      current_user_session.destroy
      @current_user_session = nil
      @current_user = nil
    end
    @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = 'You must log in to access this page.'
      redirect_to login_url
    end
  end

  def require_no_user
    if current_user || @current_user
      store_location
      if sso_net_id
        flash[:notice] = 'You must close your web browser to log out.'
        redirect_to root_url
      else
        redirect_to logout_url
      end
    end
  end

  def check_authorization
    Authorization.current_user = current_user
  end

  def store_location
    return if self == UserSessionsController
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end

