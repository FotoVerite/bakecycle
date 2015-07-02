module Users
  class InvitationsController < Devise::InvitationsController
    before_action :configure_permitted_parameters

    def send_email
      authorize current_user
      user = User.find(params[:format])
      user.invite!
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
