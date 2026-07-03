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
    parsed_date_param(:date, :id)
  end
end
