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

  describe '.sort_by_bakery_and_name' do
    it 'sorts users with bakery first and sorts by name afterwards' do
      no_bakery = create(:user, bakery: nil)
      a_bakery = create(:bakery, name: 'a bakery')
      john = create(:user, name: 'john', bakery: a_bakery)
      david = create(:user, name: 'David', bakery: a_bakery)
      bob = create(:user, name: 'bob', bakery: create(:bakery, name: 'B bakery'))
      aria = create(:user, name: 'aria', bakery: create(:bakery, name: 'c bakery'))
      expect(User.sort_by_bakery_and_name).to eq([david, john, bob, aria, no_bakery])
    end
  end
end
