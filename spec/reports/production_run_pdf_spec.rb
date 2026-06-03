require "rails_helper"

describe ProductionRunPdf do
  it "renders the critical production run content into parseable PDF text" do
    bakery = create(:bakery, name: "Bakecycle Test Bakery")
    run_date = Date.new(2026, 6, 2)
    flour = create(:ingredient, bakery: bakery, name: "Strong Flour")
    water = create(:ingredient, bakery: bakery, name: "Filtered Water")
    preferment_flour = create(:ingredient, bakery: bakery, name: "Preferment Flour")
    preferment = create(
      :recipe_preferment,
      bakery: bakery,
      name: "Levain Preferment",
      mix_size: 2,
      mix_size_unit: :kg
    )
    create(:recipe_item_ingredient, bakery: bakery, recipe: preferment, inclusionable: preferment_flour, bakers_percentage: 100)

    motherdough = create(
      :recipe_motherdough,
      bakery: bakery,
      name: "Country Dough",
      mix_size: 1,
      mix_size_unit: :kg
    )
    create(:recipe_item_ingredient, bakery: bakery, recipe: motherdough, inclusionable: flour, bakers_percentage: 100, sort_id: 1)
    create(:recipe_item_ingredient, bakery: bakery, recipe: motherdough, inclusionable: water, bakers_percentage: 70, sort_id: 2)
    create(:recipe_item_recipe, bakery: bakery, recipe: motherdough, inclusionable: preferment, bakers_percentage: 20, sort_id: 3)

    product = create(
      :product,
      bakery: bakery,
      name: "Country Loaf",
      product_type: :bread,
      weight: 100,
      unit: :g,
      motherdough: motherdough
    )
    production_run = create(:production_run, bakery: bakery, date: run_date)
    create(:run_item, bakery: bakery, production_run: production_run, product: product, order_quantity: 10, overbake_quantity: 2)

    pdf_bytes = ProductionRunPdf.new(ProductionRunData.new(production_run)).render
    text = pdf_text(pdf_bytes)

    expect(pdf_bytes).to start_with("%PDF")
    expect(pdf_page_count(pdf_bytes)).to be >= 3
    expect(text).to include("Production Run ##{production_run.id}")
    expect(text).to include("Tuesday Jun. 2, 2026")
    expect(text).to include("Bread")
    expect(text).to include("Country Loaf")
    expect(text).to include("1.200 kg")
    expect(text).to include("0.600 kg")
    expect(text).to include("Country Dough")
    expect(text).to include("Strong Flour")
    expect(text).to include("Filtered Water")
    expect(text).to include("0.316 kg")
    expect(text).to include("0.221 kg")
    expect(text).to include("Nested Recipe")
    expect(text).to include("Levain Preferment")
    expect(text).to include("Preferments")
    expect(text).to include("Preferment Flour")
    expect(text).to include("0.063 kg")
    expect(text).to include("0.126 kg")
  end

  it "renders a production run with a production run" do
    production_run = build_stubbed(:production_run)
    build_stubbed(:run_item, production_run: production_run, order_quantity: 5)
    production_run_data = ProductionRunData.new(production_run)
    pdf = ProductionRunPdf.new(production_run_data)
    expect(pdf.render).to_not be_nil
  end

  it "renders a production run with a projection run" do
    projection = new_stubed_production_run_projection
    projection_run_data = ProjectionRunData.new(projection)
    pdf = ProductionRunPdf.new(projection_run_data)

    expect(pdf.render).to_not be_nil
  end
end
