class StripeCustomerId < ActiveRecord::Migration
  def change
    add_column :bakeries, :stripe_customer_id, :string
  end
end
