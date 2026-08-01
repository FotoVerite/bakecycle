# frozen_string_literal: true

class ProductionChecklistsController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope

  # rubocop:disable Metrics/AbcSize
  def show
    candidates = policy_scope(Order).production_date(Time.zone.today)
      .includes(:bakery, :client, :route)
    missing_dates = Order.missing_shipment_dates_for(candidates)
    @missing_shipments = candidates.reject { |o| missing_dates[o.id].blank? }
    @double_invoices = Shipment.duplicate_invoices(current_bakery,
                                                   (Time.zone.today - 2.days)..(Time.zone.today + 7.days))
    @production_run = current_bakery.production_runs.find_by(date: Time.zone.today)
    @missing_items = current_bakery.shipment_items.where(production_start: Time.zone.today, production_run_id: nil)
  end

  # rubocop:enable Metrics/AbcSize
end
