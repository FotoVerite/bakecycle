# frozen_string_literal: true

class InvoicesIifGenerator
  attr_reader :bakery, :search

  include Generator

  def self.find(id)
    bakery_id, search_id = id.split("_", 2)
    new(Bakery.find(bakery_id), ShipmentSearchForm.find(search_id))
  end

  def initialize(bakery, search)
    @bakery = bakery
    @search = search
  end

  def id
    "#{bakery.id}_#{search.id}"
  end

  def filename
    Generator.client_filename_for(
      records: invoices,
      clients: bakery.clients,
      filename: "#{bakery_file_name}-QuickBooks#{date}.iif"
    )
  end

  def content_type
    "text/iif"
  end

  def generate
    InvoicesIif.new(invoices).generate
  end

  private

  def bakery_file_name
    bakery.decorate.parameterized_name
  end

  def invoices
    @_invoices ||= bakery.shipments.search(search).non_sample
  end

  def date
    date_from = invoices.minimum(:date)
    date_to = invoices.maximum(:date)
    "-#{date_from}-to-#{date_to}" if date_to && date_from
  end
end
