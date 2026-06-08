# frozen_string_literal: true

module Generator
  def self.included(base)
    base.include GlobalID::Identification
  end

  def content_type
    case File.extname(filename)
    when ".pdf"  then "application/pdf"
    when ".xlsx" then "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    when ".csv"  then "text/csv"
    when ".iif"  then "text/plain"
    else "application/octet-stream"
    end
  end
end
