class LandingPagesController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope

  def index
    expires_in 2.minutes, public: true
  end

  def sign_in
    if user_signed_in?
      redirect_to after_sign_in_path_for(current_user)
    else
      redirect_to new_user_session_path
    end
  end
end
