require 'rails_helper'

describe DemoCreator do
  it 'runs' do
    bakery = create(:bakery)
    DemoCreator.new(bakery)
  end
end
