require 'pry'
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to recipes_path, status: 300
    else
      render "new"
    end
  end

  private
    def user_params
      params.permit(:authenticity_token, :commit, :user => [:username, :password, :password_confirmation])
    end
end 
