module Users
  class InvitationsController < Devise::InvitationsController
    skip_before_action :authenticate_user!
    before_action :configure_permitted_parameters

    def send_email
      user = User.find(params[:format])
      authorize user
      user.invite!(current_user)
      set_flash_message :notice, :send_instructions, email: user.email
      redirect_to users_path
    end

    private

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:invite) do |u|
        u.permit(:password, :password_confirmation)
      end
    end
  end
end
