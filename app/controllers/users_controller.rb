class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :users, :user

  def index
    @users = @users
      .includes(:bakery)
      .joins(:bakery)
      .order('bakeries.name asc')
      .order(:name)
  end

  def new
  end

  def create
    if @user.save
      flash[:notice] = "You have created a new user for #{@user.name} with #{@user.email}"
      redirect_to edit_user_path(@user)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "You have updated #{@user.name}."
      redirect_to edit_user_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:notice] = "You have deleted #{@user.name}"
    redirect_to users_path
  end

  private

  def user_params
    user = params.require(:user).permit(:name, :email, :password, :password_confirmation, :bakery_id)
    if user[:password].blank? && user[:password_confirmation].blank?
      user.delete(:password)
      user.delete(:password_confirmation)
    end
    user
  end
end
