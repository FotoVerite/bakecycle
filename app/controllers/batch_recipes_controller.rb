class BatchRecipesController < ApplicationController
  after_action :skip_policy_scope, only: %i[index print export_csv]

  def index
    authorize ProductionRun, :can_print?
    active_nav(:batch_recipes)
    @projection = ProductionRunProjection.new(current_bakery, start_date, end_date)
  end

  def print
    authorize ProductionRun, :can_print?
    generator = BatchGenerator.new(current_bakery, start_date, end_date)
    redirect_to ExporterJob.create(current_user, current_bakery, generator)
  end

  def export_csv
    authorize ProductionRun, :can_print?
    projection = ProductionRunProjection.new(current_bakery, start_date, end_date)
    filename = "Batch_Recipes_#{projection.start_date}_#{projection.batch_end_date}.csv"
    respond_to do |format|
      format.csv {
        response.headers["Content-Disposition"] = 'attachment; filename="' + filename + '"'
        render text: BatchRecipesCsv.new(projection).to_csv
      }
    end
  end

  private

  def start_date
    Chronic.parse(params[:start_date]) || Time.zone.today
  end

  def end_date
    Chronic.parse(params[:end_date]) || Time.zone.today + 6.days
  end
end
