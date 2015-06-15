class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped
  decorates_assigned :users, :user

  def index
    authorize :user
    @users = policy_scope(User).sort_by_bakery_and_name
  end

  def new
    @user = policy_scope(User).build
    authorize @user
  end

  def create
    @user = policy_scope(User).build(user_params)
    authorize @user
    if @user.save
      flash[:notice] = "You have created a new user for #{@user.name} with #{@user.email}"
      redirect_to edit_user_path(@user)
    else
      render 'new'
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      flash[:notice] = "You have updated #{@user.name}."
      redirect_to edit_user_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    authorize @user
    @user.destroy
    flash[:notice] = "You have deleted #{@user.name}"
    redirect_to users_path
  end

  private

  def set_user
    @user = policy_scope(User).find(params[:id])
  end

  def user_params
    user = params.require(:user).permit(policy(User).permitted_attributes)
    delete_passwords_if_blank(user)
    user
  end

  def delete_passwords_if_blank(user)
    return unless user[:password].blank? && user[:password_confirmation].blank?
    user.delete(:password)
    user.delete(:password_confirmation)
  end
end
