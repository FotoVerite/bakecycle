class DailyTotalsController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope

  def index
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    generator = DailyTotalGenerator.new(current_bakery, date_query, params[:show_routes])
    redirect_to ExporterJob.create(current_bakery, generator)
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end
end
