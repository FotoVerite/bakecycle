class StripeUserCreateJob < ApplicationJob
  queue_as :payments

  def perform(user, token)
    return if user.bakery.stripe_customer_id
    customer = Stripe::Customer.create(
      email: user.email,
      card: token
    )
    user.bakery.update!(stripe_customer_id: customer.id)
  rescue Resque::TermException
    Resque.logger.error "Resque job termination re-queuing #{self} #{user}"
    self.class.perform_later(user, token)
  end
end
