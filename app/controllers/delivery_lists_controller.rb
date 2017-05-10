class DeliveryListsController < ApplicationController
  before_action :skip_policy_scope

  def index
    authorize Route
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    authorize Route, :print?
    generator = DeliveryListGenerator.new(current_bakery, date_query)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end
end
