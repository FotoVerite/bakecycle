class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  decorates_assigned :users, :user

  def index
    authorize User
    @users = policy_scope(User).sort_by_bakery_and_name
  end

  def new
    @user = policy_scope(User).build
    authorize @user
  end

  def create
    @user = policy_scope(User).build(user_params)
    authorize @user

    if params[:user][:password].present?
      create_user
    else
      invite_user
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
    @user.destroy!
    flash[:notice] = "You have deleted #{@user.name}"
    redirect_to users_path
  end

  def myaccount
    @user = policy_scope(User).find(current_user)
    active_nav(:my_user)
    authorize @user, :edit?
    render 'edit'
  end

  private

  def invite_user
    @user.password = temp_password
    @user.password_confirmation = temp_password

    if @user.valid?
      @user.invite!(current_user)
      flash[:notice] = t('devise.invitations.send_instructions', email: @user.email)
      redirect_to users_path
    else
      render :new
    end
  end

  def create_user
    if @user.save
      flash[:notice] = t('devise.invitations.user.user_added', email: user.email)
      redirect_to users_path
    else
      render :new
    end
  end

  def temp_password
    @_temp_password ||= SecureRandom.hex
  end

  def set_user
    @user = policy_scope(User).find(params[:id])
  end

  def user_params
    user = params.require(:user).permit(policy(User).permitted_attributes)
    delete_passwords_if_blank(user)
    user
  end

  def delete_passwords_if_blank(user)
    return if password_present?
    user.delete(:password)
    user.delete(:password_confirmation)
  end

  def password_present?
    params[:user][:password].present? && params[:user][:password_confirmation].present?
  end
end
