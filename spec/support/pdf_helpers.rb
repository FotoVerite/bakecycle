# frozen_string_literal: true

require "pdf/reader"

module PdfHelpers
  def pdf_text(pdf_bytes)
    reader = PDF::Reader.new(StringIO.new(pdf_bytes))
    reader.pages.map(&:text).join("\n")
  end

  def pdf_page_count(pdf_bytes)
    PDF::Reader.new(StringIO.new(pdf_bytes)).page_count
  end
end

RSpec.configure do |config|
  config.include PdfHelpers
end
