# frozen_string_literal: true

class BatchRecipesController < ApplicationController
  include ExportsReportable

  after_action :skip_policy_scope, only: %i[index print export_csv]

  def index
    authorize ProductionRun, :can_print?
    active_nav(:batch_recipes)
    @projection = ProductionRunProjection.new(current_bakery, start_date, end_date)
  end

  def print
    authorize ProductionRun, :can_print?
    generator = BatchGenerator.new(current_bakery, start_date, end_date)
    create_export_and_respond(generator)
  end

  def export_csv
    authorize ProductionRun, :can_print?
    generator = BatchRecipesCsvGenerator.new(current_bakery, start_date, end_date)
    create_export_and_respond(generator)
  end

  private

  def start_date
    parsed_date_param(:start_date)
  end

  def end_date
    parsed_date_param(:end_date, fallback: Time.zone.today + 6.days)
  end
end
