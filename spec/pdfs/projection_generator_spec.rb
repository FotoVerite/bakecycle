require 'rails_helper'

describe ProjectionGenerator do
  it 'has a shape' do
    bakery = create(:bakery)
    generator = ProjectionGenerator.new(bakery, Time.zone.today)
    expect(generator.filename).to eq('ProjectionRunRecipe.pdf')
    expect(generator.generate).to_not be_nil
  end
end
