class UsersController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def index
    @users = User.accessible_by(current_ability)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.bakery = current_bakery
    if @user.save
      flash[:notice] = "You have created a new user for #{@user.name} with #{@user.email}"
      redirect_to edit_user_path(@user)
    else
      render 'new'
    end
  end

  def edit
    @user = User.accessible_by(current_ability).find(params[:id])
  end

  def update
    @user = User.accessible_by(current_ability).find(params[:id])
    if @user.update(user_params)
      flash[:notice] = "You have updated #{@user.name}."
      redirect_to edit_user_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    User.accessible_by(current_ability).destroy(params[:id])
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
