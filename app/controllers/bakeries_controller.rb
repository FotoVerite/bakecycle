class BakeriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  decorates_assigned :bakeries, :bakery

  def index
  end

  def new
    @bakery = Bakery.new(
      kickoff_time: Chronic.parse('2 pm'),
      quickbooks_account: 'Sales:Sales - Wholesale'
    )
  end

  def create
    if @bakery.save
      create_demo_data
      flash[:notice] = "You have created #{@bakery.name}."
      redirect_to bakeries_path
    else
      render 'new'
    end
  end

  def edit
  end

  def mybakery
    active_nav(:my_bakery)
    @bakery = current_bakery
    render 'edit'
  end

  def update
    if @bakery.update(bakery_params)
      flash[:notice] = "You have updated #{@bakery.name}."
      redirect_to edit_bakery_path(@bakery)
    else
      render 'edit'
    end
  end

  def destroy
    @bakery.destroy!
    flash[:notice] = "You have deleted #{@bakery.name}"
    redirect_to bakeries_path
  end

  private

  def create_demo_data
    DemoCreator.new(@bakery).run if params[:set_demo_data]
  end

  def bakery_params
    params.require(:bakery).permit(
      :name,
      :logo,
      :email,
      :phone_number,
      :address_street_1,
      :address_street_2,
      :address_city,
      :address_state,
      :address_zipcode,
      :kickoff_time,
      :quickbooks_account,
      :group_preferments
    )
  end
end
