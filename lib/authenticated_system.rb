module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user != :false
    end
    
    # Accesses the current user from the session.
    def current_user
      @current_user ||= (session[:user] && User.find_by_net_id(session[:user])) || :false
    end
    
    # Store the given user in the session.
    def current_user=(new_user)
      new_user.login! unless new_user.net_id == session[:user]
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.net_id
      @current_user = new_user
    end

    # Filter method to enforce a login requirement. Uses CUWA first, then
    # HTTP Basic if that fails. In development, will prompt for Basic auth.
    # We create people who login but aren't already in the system
    def login_required
      @net_id = request.env['HTTP_REMOTE_USER'] || get_auth_data.first
    request_basic_auth if development? && !@net_id
      self.current_user = User.find_or_create_by_net_id(@net_id) if @net_id
    end

    # Store the URI of the current request in the session.
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

  private

    def development?
      RAILS_ENV == 'development'
    end
    
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end

    def request_basic_auth
      headers["Status"]           = "Unauthorized"
      headers["WWW-Authenticate"] = %(Basic realm="Login Required")
      render :text => "Could't authenticate you", :status => 401
    end
    
end
