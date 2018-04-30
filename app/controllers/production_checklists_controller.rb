class ProductionChecklistsController < ApplicationController

   before_action :skip_authorization, :skip_policy_scope

    def show
      @missing_shipments = policy_scope(Order).production_date(Time.zone.today)
      .reject(&:no_outstanding_shipments?)
      @double_invoices = Shipment.where(
      "bakery_id = ? AND date between ? and ? ",
      current_bakery,
      (Time.zone.today - 2.days),
      (Time.zone.today + 3.days)
    )
      .group_by { |e| [e.date, e.client_id, e.route_id] }
      .select { |_k, v| v.size > 1 }.values.flatten
      @production_run = current_bakery.production_run.find_by(date: Time.zone.today)
      @missing_items = current_bakery.shipment_items.where(production_start: Time.zone.today, production_run_id: nil) 
    end

end
