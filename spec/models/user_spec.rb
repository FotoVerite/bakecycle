require 'rails_helper'

describe User do
  let(:user) { build(:user) }

  it 'has association' do
    expect(user).to belong_to(:bakery)
  end

  describe 'validations' do
    it { expect(user).to validate_length_of(:name).is_at_most(150) }
    it { expect(user).to validate_presence_of(:email) }
    it { expect(user).to validate_uniqueness_of(:email) }
  end
end
