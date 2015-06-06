class DailyTotalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    generator = DailyTotalGenerator.new(current_bakery, date_query)
    redirect_to ExporterJob.create(current_bakery, generator)
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end
end
