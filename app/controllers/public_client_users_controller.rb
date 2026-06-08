# frozen_string_literal: true

class PublicClientUsersController < ApplicationController
  def index
    authorize PublicClientUser
    @users = policy_scope(PublicClientUser)
  end

  def new
    authorize PublicClientUser
    @user = policy_scope(PublicClientUser).new
  end

  def create
    authorize PublicClientUser
    @user = policy_scope(PublicClientUser).new(user_params)
    if @user.valid? && @user.publish_user
      redirect_to public_client_users_path
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:public_client_user).permit(policy(PublicClientUser).permitted_attributes)
  end
end
