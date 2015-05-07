class DbaDbNothing < ActiveRecord::Migration
  def change
    rename_column :clients, :dba, :official_company_name
    rename_column :shipments, :client_dba, :client_official_company_name
    add_column :clients, :ein, :string

    change_column_null :shipments, :date, false
    change_column_null :shipments, :payment_due_date, false
    change_column_null :shipments, :delivery_fee, false

    change_column_null :shipments, :client_id, false
    change_column_null :shipments, :client_name, false
    change_column_null :shipments, :client_billing_term, false
    change_column_null :shipments, :client_billing_term_days, false

    change_column_null :shipments, :route_id, false
    change_column_null :shipments, :route_name, false

  end
end
