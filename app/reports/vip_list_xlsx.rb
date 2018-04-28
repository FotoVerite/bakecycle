class VipListXlsx
  def initialize(bakery)
    @bakery = bakery
    @clients = bakery.clients.order("Name ASC")
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :center }
    @bold = styles.add_style sz: 12, b: true
    wb.add_worksheet(name: "Vip List #{Time.zone.today}") do |sheet|
      sheet.add_row ["VIPS"], style: [@header]
      @clients.vips.each do |vip|
        sheet.add_row [vip.name]
      end
      sheet.add_row ["TEMP VIPS"], style: [@header]
      @clients.temp_vips.each do |vip|
        sheet.add_row [vip.name]
      end
    end
    create_output_string(p)
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
