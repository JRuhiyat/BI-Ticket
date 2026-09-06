class ApplicationController < ActionController::Base
  # In local offline mode, login is bypassed so users can access dashboard directly
  # before_action :require_login
  
  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) || User.new(name: "Local User", email: "local@offline")
  end
  helper_method :current_user
  
  def require_login
    # Direct access allowed in local offline mode
    true
  end
end
