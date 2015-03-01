require 'rails_helper'

describe Route do
  let(:route) { build(:route) }

  it 'has model attributes' do
    expect(route).to respond_to(:name)
    expect(route).to respond_to(:notes)
    expect(route).to respond_to(:active)
    expect(route).to respond_to(:departure_time)
  end

  it 'has association' do
    expect(route).to belong_to(:bakery)
  end

  it 'has validations' do
    expect(route).to validate_presence_of(:name)
    expect(route).to ensure_length_of(:name).is_at_most(150)
    expect(route).to validate_presence_of(:departure_time)
    expect(route).to validate_uniqueness_of(:name).scoped_to(:bakery_id)

    route.active = nil
    expect(route).to_not be_valid
  end

  it 'can have same name if are apart of different bakeries' do
    biencuit = create(:bakery)
    route_name = 'Midnight'
    create(:route, name: route_name, bakery: biencuit)
    expect(create(:route, name: route_name)).to be_valid
  end

  it 'is a time' do
    expect(build(:route, departure_time: Time.now)).to be_valid
    expect(build(:route, departure_time: 'it is not a time')).to_not be_valid
  end
end
