class BakeriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    if @bakery.save
      flash[:notice] = "You have created #{@bakery.name}."
      redirect_to bakeries_path
    else
      render 'new'
    end
  end

  def edit
  end

  def mybakery
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

  def bakery_params
    params.require(:bakery).permit(
      :name, :logo, :email, :phone_number, :address_street_1,
      :address_street_2, :address_city, :address_state, :address_zipcode
      )
  end
end
