class BakeriesController < ApplicationController
  before_action :set_bakery, only: [:edit, :update, :destroy]
  decorates_assigned :bakeries, :bakery

  def index
    authorize Bakery
    @bakeries = policy_scope(Bakery)
  end

  def new
    @bakery = policy_scope(Bakery).build(
      kickoff_time: Chronic.parse("5 pm"),
      quickbooks_account: "Sales:Sales - Wholesale"
    )
    authorize @bakery
  end

  def create
    @bakery = policy_scope(Bakery).build(bakery_params)
    authorize @bakery
    if @bakery.save
      create_demo_data
      flash[:notice] = "You have created #{@bakery.name}."
      redirect_to bakeries_path
    else
      render "new"
    end
  end

  def edit
    authorize @bakery
  end

  def update
    authorize @bakery
    if @bakery.update(bakery_params)
      flash[:notice] = "You have updated #{@bakery.name}."
      redirect_to edit_bakery_path(@bakery)
    else
      render "edit"
    end
  end

  def destroy
    authorize @bakery
    @bakery.destroy!
    flash[:notice] = "You have deleted #{@bakery.name}"
    redirect_to bakeries_path
  end

  def mybakery
    active_nav(:my_bakery)
    @bakery = policy_scope(Bakery).find(current_bakery)
    authorize @bakery, :edit?
    render "edit"
  end

  private

  def create_demo_data
    DemoCreatorJob.perform_later(@bakery) if params[:set_demo_data]
  end

  def set_bakery
    @bakery = policy_scope(Bakery).find(params[:id])
  end

  def bakery_params
    params.require(:bakery).permit(policy(Bakery).permitted_attributes)
  end
end
