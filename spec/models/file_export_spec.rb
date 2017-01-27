# == Schema Information
#
# Table name: file_exports
#
#  id                :uuid             not null, primary key
#  bakery_id         :integer          not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_fingerprint  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require "rails_helper"

describe FileExport do
  let(:file_export) { build_stubbed(:file_export) }

  it "has a shape" do
    expect(file_export).to respond_to(:bakery)
    expect(file_export).to respond_to(:file)
  end
end
