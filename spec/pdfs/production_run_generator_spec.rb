require 'rails_helper'

describe ProductionRunGenerator do
  it 'has a shape' do
    production_run = create(:run_item).production_run
    generator = ProductionRunGenerator.new(production_run)
    expect(generator.filename).to eq('ProductionRunRecipe.pdf')
    expect(generator.generate).to_not be_nil
  end
end
