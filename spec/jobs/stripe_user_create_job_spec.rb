require 'stripe_mock'
require 'rails_helper'

describe StripeUserCreateJob do
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:user) { create(:user) }
  let(:token) { stripe_helper.generate_card_token }

  describe '#perform' do
    it 'creates a customer for stripe' do
      expect(Stripe::Customer).to receive(:create).with(email: user.email, card: token).and_call_original
      StripeUserCreateJob.new.perform(user, token)
      expect(user.bakery.stripe_customer_id).to_not be_nil
    end

    it 'is idempotent' do
      expect(Stripe::Customer).to receive(:create).once.and_call_original
      StripeUserCreateJob.new.perform(user, token)
      customer_id = user.bakery.stripe_customer_id
      StripeUserCreateJob.new.perform(user, token)
      expect(Bakery.last.stripe_customer_id).to eq(customer_id)
    end

    it 're-enqueues itself when terminated' do
      expect(user.bakery).to receive(:update!).and_raise(Resque::TermException, 'TERM')
      expect { StripeUserCreateJob.new.perform(user, token) }.to enqueue_a(StripeUserCreateJob)
    end
  end
end
