class RegistrationsController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope

  def new
    if user_signed_in?
      flash[:notice] = 'You are already registered.'
      return redirect_to dashboard_path
    end
    @registration = Registration.new(plan: selected_plan || default_plan)
  end

  def create
    @registration = Registration.new(registration_params)
    if @registration.save_with_demo
      sign_in @registration.user
      flash[:notice] = 'Thank you for registering with BakeCycle.'
      redirect_to dashboard_path
    else
      render 'new'
    end
  end

  private

  def default_plan
    Plan.find_by(name: 'beta_large')
  end

  def selected_plan
    Plan.find_by(name: params[:plan])
  end

  def registration_params
    params.require(:registration).permit(:first_name, :last_name, :bakery_name, :email, :password, :plan_id)
  end
end
