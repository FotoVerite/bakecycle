class DailyTotalsController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope

  def index
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    generator = DailyTotalGenerator.new(current_bakery, date_query, params[:format] || "pdf", params[:show_routes])
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  private

  def date_query
    parsed_date_param(:date, :id)
  end
end
