class BatchRecipesController < ApplicationController
  after_action :skip_policy_scope, only: [:index, :print]

  def index
    authorize ProductionRun, :can_print?
    active_nav(:batch_recipes)
    @projection = ProductionRunProjection.new(current_bakery, start_date, end_date)
  end

  def print
    authorize ProductionRun, :can_print?
    generator = BatchGenerator.new(current_bakery, start_date, end_date)
    redirect_to ExporterJob.create(current_bakery, generator)
  end

  private

  def start_date
    Chronic.parse(params[:start_date]) || Time.zone.today
  end

  def end_date
    Chronic.parse(params[:end_date]) || Time.zone.today + 6.days
  end
end
