# frozen_string_literal: true

class PackingSlipsGenerator
  include Generator
  composite_id bakery: :bakery, date: :date, print_invoices: :bool

  def initialize(bakery, date, print_invoices)
    @bakery = bakery
    @date = date.to_date
    @print_invoices = print_invoices
  end

  def filename
    "Packing-Slips-#{@date.iso8601}.pdf"
  end

  def generate
    pdf.render
  end

  private

  def pdf
    PackingSlipsPdf.new(shipments, @bakery, @print_invoices)
  end

  def shipments
    Shipment.where(bakery: @bakery).search(date: @date).order_by_route_and_client.includes(:shipment_items)
  end
end
