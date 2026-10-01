# frozen_string_literal: true

require "rails_helper"
require "net/http"

RSpec.describe "Test production runs", type: :system do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }

  it "prints a test production packet with multiple products and their quantities" do
    dough = create(:recipe_motherdough, bakery: bakery, name: "Test Bread Dough", mix_size: 1, mix_size_unit: :kg)
    flour = create(:ingredient, bakery: bakery, name: "Test Bread Flour")
    create(:recipe_item_ingredient, bakery: bakery, recipe: dough, inclusionable: flour, bakers_percentage: 100)
    products = ["Test Country Loaf", "Test Baguette", "Test Dinner Rolls"].map do |name|
      create(:product, bakery: bakery, name: name, product_type: :bread, motherdough: dough,
                       weight: 100, unit: :g, over_bake: 0)
    end
    production_run = create(:production_run, bakery: bakery)
    create(:run_item, bakery: bakery, production_run: production_run, product: products.first, order_quantity: 1)
    login_as user, scope: :user

    visit dashboard_path
    within 'nav[aria-label="Primary navigation"]' do
      find("summary", text: /production/i).click
      click_link "Production Runs", exact: true
    end
    find("#production_run_#{production_run.id} td[data-title='Id']").click
    click_link "Create Test Production Run"
    expect(page).to have_content("Create A Test Production Run")

    products.zip([25, 40, 60]).each_with_index do |(product, quantity), index|
      click_button "Add Product" if index.positive?
      expect(page).to have_css('[data-production-run-items-target="rows"] tr', count: index + 1)
      within all('[data-production-run-items-target="rows"] tr').last do
        select product.name, from: "Product"
        fill_in "Overbake quantity", with: quantity
      end
    end

    # Removing an extra row must not send an empty product to the PDF generator.
    click_button "Add Product"
    within all('[data-production-run-items-target="rows"] tr').last do
      click_button "X"
    end
    expect(page).to have_css('[data-production-run-items-target="rows"] tr', count: 3)
    products.zip([25, 40, 60]).each_with_index do |(product, quantity), index|
      within all('[data-production-run-items-target="rows"] tr')[index] do
        expect(page).to have_select("Product", selected: product.name)
        expect(page).to have_field("Overbake quantity", with: quantity.to_s)
      end
    end

    click_button "Print"
    expect(page).to have_css('#export_tray_list [data-export-state="pending"]', visible: :all)
    expect(FileExport.where(user: user).count).to eq(1)
    perform_enqueued_jobs(only: ExporterJob)
    export = FileExport.find_by!(user: user)
    expect(export).to be_ready
    expect(export).not_to be_failed
    expect(export.file_file_name).to eq("Production-Run-Projection-#{Time.zone.today.iso8601}.pdf")

    text = pdf_text(File.binread(export.file.path))
    products.zip([25, 40, 60]).each do |product, quantity|
      expect(text).to match(/#{Regexp.escape(product.name)}\s+#{quantity}\b/)
    end
    expect(text).to include("Production Run PROJECTION", "Test Bread Flour")
    # PDF text extraction can insert spaces between letters in large headings.
    expect(text.gsub(/\s/, "")).to include("TestBreadDough")

    visit file_exports_path
    within "#file_export_#{export.id}" do
      expect(page).to have_content("Ready")
      expect(page).to have_link("Download", href: file_export_path(export))
    end

    within "#file_export_#{export.id}" do
      # Chrome opens local PDFs in its viewer; Cuprite's click helper waits for
      # a normal HTML page to load. Trigger the link and check its destination.
      page.execute_script("arguments[0].click()", find_link("Download"))
    end
    expect(page).to have_current_path(export.download_url, ignore_query: true)
    response = Net::HTTP.get_response(URI(page.current_url))
    expect(response.code).to eq("200")
    expect(response.content_type).to eq("application/pdf")
    expect(pdf_text(response.body)).to eq(text)
  end
end
