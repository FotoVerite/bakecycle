class DeliveryListsController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization, :skip_policy_scope

  def index
    @recipes = ProductCounter.new(current_bakery, date_query)
  end

  def print
    pdf = DeliveryListPdf.new(date_query, current_bakery)
    pdf_name = 'deliverylist.pdf'
    expires_now
    send_data pdf.render, filename: pdf_name, type: 'application/pdf', disposition: 'inline'
  end

  private

  def date_query
    Chronic.parse(params[:date] || params[:id]) || Time.zone.today
  end
end
