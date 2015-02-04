class BakeriesController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def index
    @bakeries = Bakery.all
  end

  def new
    @bakery = Bakery.new
  end

  def create
    @bakery = Bakery.new(bakery_params)
    if @bakery.save
      flash[:notice] = "You have created #{@bakery.name}."
      redirect_to bakeries_path
    else
      render 'new'
    end
  end

  def edit
    @bakery = Bakery.find(params[:id])
  end

  def update
    @bakery = Bakery.find(params[:id])
    if @bakery.update(bakery_params)
      flash[:notice] = "You have updated #{@bakery.name}."
      redirect_to edit_bakery_path(@bakery)
    else
      render 'edit'
    end
  end

  def destroy
    bakery = Bakery.destroy(params[:id])
    flash[:notice] = "You have deleted #{bakery.name}"
    redirect_to bakeries_path
  end

  private

  def bakery_params
    params.require(:bakery).permit(:name)
  end
end
