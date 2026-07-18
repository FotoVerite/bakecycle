# frozen_string_literal: true

class BakeListsController < ApplicationController
  include ExportsReportable

  before_action :skip_authorization, :skip_policy_scope

  def index
    @bake_date = date_query
  end

  def print
    generator = BakeListGenerator.new(current_bakery, date_query)
    create_export_and_respond(generator)
  end

  private

  def date_query
    # Bake List is only ever generated for the next day's production, so
    # default the picker to tomorrow rather than ApplicationController's
    # usual today-fallback.
    parsed_date_param(:date, :id, fallback: Time.zone.tomorrow)
  end
end
