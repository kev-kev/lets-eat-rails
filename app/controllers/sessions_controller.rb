class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: login_params[:username])
    if user && user.authenticate(login_params[:password])
      session[:user_id] = user.id
      redirect_to recipes_path, status: 302
    else
      flash[:alert] = "invalid username or password"
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, status: 302
  end

  private
    def login_params
      params.permit(:authenticity_token, :commit, :username, :password)
    end
end
