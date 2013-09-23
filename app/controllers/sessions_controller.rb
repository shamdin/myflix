class SessionsController < ApplicationController

  def new
    redirect_to videos_path if logged_in? # videos_path is 
  end
  
  def create
    #check the database to see if user exists via email parameter    
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id 
      flash[:notice] = "Successfully logged in, welcome #{current_user.full_name}"
      redirect_to videos_path
    else
      flash[:error] = "Invalid username/password. Please try again"
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:error] = "You've logged out"
    redirect_to root_path
  end

end