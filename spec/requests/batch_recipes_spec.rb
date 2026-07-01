# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BatchRecipes", type: :request do
  let(:bakery) { create(:bakery) }
  let(:user)   { create(:user, bakery: bakery, production_permission: "manage") }

  before { sign_in user }

  describe "GET export_csv" do
    it "starts an async export instead of rendering CSV synchronously" do
      file_export = create(:file_export, bakery: bakery)
      allow(ExporterJob).to receive(:create).and_return(file_export)

      get export_csv_batch_recipes_path(start_date: "2026-07-01", end_date: "2026-07-07")

      expect(ExporterJob).to have_received(:create).with(
        user,
        bakery,
        an_instance_of(BatchRecipesCsvGenerator)
      )
      expect(response).to redirect_to(file_export)
    end
  end
end
