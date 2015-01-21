class AddBillingTermsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :billing_term, :integer, null: false
  end
end
