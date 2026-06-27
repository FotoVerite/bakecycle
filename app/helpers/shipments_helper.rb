# frozen_string_literal: true

module ShipmentsHelper
  def invoice_search_scope_description(search_form, shipments)
    parts = []
    prefix = search_form[:sequence_number].to_s.strip
    client_names = selected_invoice_filter_names(shipments.available_clients, search_form[:client_id])
    product_names = selected_invoice_filter_names(shipments.available_products, search_form[:product_id])
    date_from = search_form[:date_from]
    date_to = search_form[:date_to]

    parts << "Invoice prefix: #{prefix}" if prefix.present?
    parts << "Clients: #{summarize_invoice_filter_names(client_names)}" if client_names.any?
    parts << "Products: #{summarize_invoice_filter_names(product_names)}" if product_names.any?
    parts << invoice_date_scope_description(date_from, date_to) if date_from || date_to

    parts.presence&.join(" · ") || "All invoices"
  end

  private

  def selected_invoice_filter_names(scope, ids)
    selected_ids = Array(ids).reject(&:blank?).map(&:to_i)
    return [] if selected_ids.empty?

    scope.where(id: selected_ids).pluck(:name)
  end

  def summarize_invoice_filter_names(names)
    visible_names = names.first(2)
    remaining_count = names.length - visible_names.length
    return visible_names.join(", ") if remaining_count.zero?

    "#{visible_names.join(', ')} +#{remaining_count} more"
  end

  def invoice_date_scope_description(date_from, date_to)
    return "Delivery dates: #{invoice_scope_date(date_from)} to #{invoice_scope_date(date_to)}" if date_from && date_to
    return "Delivery date from: #{invoice_scope_date(date_from)}" if date_from

    "Delivery date through: #{invoice_scope_date(date_to)}"
  end

  def invoice_scope_date(date)
    date.strftime("%B %-d, %Y")
  end
end
