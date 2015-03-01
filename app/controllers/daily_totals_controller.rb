class DailyTotalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = RecipeService.new(date_query)
  end

  def print
    pdf = DailyTotalPdf.new(date_query)
    pdf_name = 'dailytotal.pdf'
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Date.today
  end
end
