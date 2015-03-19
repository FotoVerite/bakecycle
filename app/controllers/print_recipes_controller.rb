class PrintRecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @date = date_query
    @products = RecipeRun.new(@date, item_finder.shipment_items).collection
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Date.today
  end
end
