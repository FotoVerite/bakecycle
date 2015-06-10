require 'rails_helper'

describe User do
  let(:user) { build(:user) }

  it 'has association' do
    expect(user).to belong_to(:bakery)
  end

  it 'has validations' do
    expect(user).to validate_length_of(:name)
    expect(user).to validate_presence_of(:user_permission)
    expect(user).to validate_inclusion_of(:user_permission).in_array(User::ACCESS_LEVELS)
    expect(user).to validate_presence_of(:email)
    expect(user).to validate_uniqueness_of(:email)
  end

  describe '.sort_by_bakery' do
    it 'sorts users with no bakery first' do
      no_bakery = create(:user, bakery: nil)
      a_bakery = create(:user, bakery: create(:bakery, name: 'a bakery'))
      b_bakery = create(:user, bakery: create(:bakery, name: 'B bakery'))
      expect(User.sort_by_bakery).to eq([a_bakery, b_bakery, no_bakery])
    end
  end
end
