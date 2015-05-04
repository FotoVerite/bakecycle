class DailyTotalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = ProductCounter.new(date_query, current_bakery)
  end

  def print
    pdf = DailyTotalPdf.new(date_query, current_bakery)
    pdf_name = 'dailytotal.pdf'
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end
end
