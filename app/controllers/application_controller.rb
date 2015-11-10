class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def check_session
#Check if user is logged in 
    if current_user
#Check if user belongs
    then 
      if current_user.id=="1"
      then
        fail
      end
    else
      redirect_to login_url
    end
  end
 
  helper_method :current_user
end
