class DeliveryListsController < ApplicationController
  before_action :skip_policy_scope

  def index
    authorize Route
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    authorize Route, :print?
    generator = DeliveryListGenerator.new(current_bakery, date_query, params[:type])
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def print_sorted
    authorize Route, :print?
    generator = SortedDeliveryListGenerator.new(current_bakery, date_query)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  private

  def date_query
    parsed_date_param(:date, :id)
  end
end
