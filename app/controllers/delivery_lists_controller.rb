class DeliveryListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @recipes = RecipeService.new(date_query, current_bakery)
  end

  def print
    pdf = DeliveryListPdf.new(date_query, current_bakery)
    pdf_name = 'deliverylist.pdf'
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Date.today
  end
end
