# frozen_string_literal: true

class DailyTotalsController < ApplicationController
  include ExportsReportable

  before_action :skip_authorization, :skip_policy_scope

  def index
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    generator = DailyTotalGenerator.new(current_bakery, date_query, params[:format] || "pdf", params[:show_routes])
    create_export_and_respond(generator)
  end

  private

  def date_query
    parsed_date_param(:date, :id)
  end
end
