class PrintRecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    @date = date_query
    @production_run = item_finder.production_runs.for_date(@date).last
  end

  private

  def date_query
    Chronic.parse(params[:date] || Date.today)
  end
end
