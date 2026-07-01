# frozen_string_literal: true

class DeliveryListsController < ApplicationController
  include ExportsReportable

  before_action :skip_policy_scope

  def index
    authorize Route
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    authorize Route, :print?
    generator = DeliveryListGenerator.new(current_bakery, date_query, params[:type])
    create_export_and_respond(generator)
  end

  def print_sorted
    authorize Route, :print?
    generator = SortedDeliveryListGenerator.new(current_bakery, date_query)
    create_export_and_respond(generator)
  end

  private

  def date_query
    parsed_date_param(:date, :id)
  end
end
