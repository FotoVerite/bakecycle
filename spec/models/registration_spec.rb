require 'rails_helper'

describe Registration do
  let(:plan) { create(:plan) }

  it 'creates a bakery and user' do
    registration = build(:registration, plan: plan)
    expect(registration.save).to eq(true)
    expect(User.count).to eq(1)
    expect(Bakery.count).to eq(1)

    user = registration.user
    bakery = registration.bakery
    expect(user.bakery).to eq(bakery)
  end

  it 'creates a user with full access to their bakery' do
    registration = create(:registration)
    user = registration.user
    permissions = user.attributes.keys.select { |key| /permission$/.match key }
    expect(permissions).to_not be_empty
    permissions.each do |permission|
      expect(user.send(permission)).to eq('manage')
    end
  end

  it 'requires a first and last name' do
    registration = build(:registration, plan: plan, first_name: nil, last_name: nil)
    expect(registration.save).to eq(false)
    expect(registration.errors[:first_name]).to include("can't be blank")
    expect(registration.errors[:last_name]).to include("can't be blank")
  end

  it "doesn't create anything if there's an error with the bakery" do
    create(:bakery, name: 'agoria')
    registration = build(:registration, plan: plan, bakery_name: 'agoria')
    expect(registration.save).to eq(false)
    expect(registration.errors[:bakery_name]).to include('has already been taken')
    expect(User.count).to eq(0)
    expect(Bakery.count).to eq(1)
  end

  it "doesn't create anything when there's an error with the user" do
    create(:user, bakery: nil, email: 'whatever@email.com')
    registration = build(:registration, plan: plan, email: 'whatever@email.com')
    expect(registration.save).to eq(false)
    expect(registration.errors[:email]).to include('has already been taken')
    expect(User.count).to eq(1)
    expect(Bakery.count).to eq(0)
  end

  it 'has an invalid plan but gives a good error message' do
    registration = build(:registration, plan: nil)
    expect(registration.save).to eq(false)
    expect(registration.errors[:plan]).to include("can't be blank")
    expect(registration.errors[:base]).to contain_exactly('We had a problem creating your bakery')
  end

  describe '#save_and_setup' do
    it 'creates demo data and stripe customer' do
      expect_any_instance_of(DemoCreator).to receive(:run)
      expect(StripeUserCreateJob).to receive(:perform_later)
      registration = build(:registration, plan: plan)
      expect(registration.save_and_setup).to eq(true)
    end

    it "doesn't create demo data or stripe customer if things are invalid" do
      expect_any_instance_of(DemoCreator).to_not receive(:run)
      expect(StripeUserCreateJob).to_not receive(:perform_later)
      registration = build(:registration, plan: plan, first_name: nil, last_name: nil)
      expect(registration.save_and_setup).to eq(false)
    end
  end
end
