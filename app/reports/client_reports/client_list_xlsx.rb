class ClientListXlsx
  def initialize(bakery, date, type)
    @bakery = bakery
    @date = date
    @clients = @bakery.clients.order_by_name
    @clients = @clients.where(active: type) unless type == "any"
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :left }
    wb.add_worksheet(name: "Client List for #{@date}") do |sheet|
      sheet.add_row(
        [
          "Client Name",
          "Active",
          "Delivery Address",
          "Business Phone",
          "Date Added",
          "Date of First Order",
          "Primary Contact Name",
          "Primary Contact Phone",
          "Primary Contact Email",
          "Accounts Payable Contact",
          "Accounts Payable Phone",
          "Accounts Payable Email",
          "Group",
          "Channel",
          "Billing Terms",
        ], header: @header,
      )
      add_rows(@clients, sheet)
    end
    create_output_string(p)
  end

  def add_rows(clients, sheet)
    # Set Product Type Row
    clients.each do |p|
      sheet.add_row [
        p.name,
        (p.active ? "Yes" : "No"),
        p.delivery_address.full,
        p.business_phone,
        p.created_at.strftime("%-m/%d/%y"),
        p.orders.order(:created_at).first.start_date.try(:strftime, "%-m/%d/%y"),
        p.primary_contact_name,
        p.primary_contact_phone,
        p.primary_contact_email,
        p.accounts_payable_contact_name,
        p.accounts_payable_contact_phone,
        p.accounts_payable_contact_email,
        p.group,
        p.channel,
        p.billing_term ? p.billing_term.humanize(capitalize: false).titleize : "None",
      ]
    end
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
