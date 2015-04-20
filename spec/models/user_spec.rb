require 'rails_helper'

describe User do
  let(:user) { build(:user) }
  let(:admin) { build(:admin) }

  it 'has model attributes' do
    expect(user).to respond_to(:name)
    expect(user).to respond_to(:email)
    expect(user).to respond_to(:admin?)
  end

  it 'has association' do
    expect(user).to belong_to(:bakery)
  end

  describe 'validations' do
    describe 'name' do
      it { expect(user).to validate_length_of(:name).is_at_most(150) }
    end

    describe 'email' do
      it { expect(user).to validate_presence_of(:email) }
      it { expect(user).to validate_uniqueness_of(:email) }
      it { expect(build(:user, email: 'Not an email')).to_not be_valid }
      it { expect(build(:user, email: 'proper@email.com')).to be_valid }
    end

    describe 'password' do
      describe 'password length' do
        it { expect(build(:user, password: 'short', password_confirmation: 'short')).to_not be_valid }
        it { expect(build(:user, password: 'longer_password', password_confirmation: 'longer_password')).to be_valid }
      end
    end
  end
end
