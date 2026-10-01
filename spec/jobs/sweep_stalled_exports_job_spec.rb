# frozen_string_literal: true

require "rails_helper"

describe SweepStalledExportsJob do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }

  def stalled_export(created_at:)
    FileExport.create!(bakery: bakery, user: user).tap do |export|
      export.update_column(:created_at, created_at)
    end
  end

  it "attaches an error report to an export whose job never came back" do
    export = stalled_export(created_at: 3.hours.ago)

    expect(described_class.new.perform).to eq(1)

    export.reload
    expect(export).to be_ready
    expect(export).to be_failed
  end

  it "leaves a recently queued export alone" do
    export = stalled_export(created_at: 2.minutes.ago)

    expect(described_class.new.perform).to eq(0)
    expect(export.reload.file).to be_blank
  end

  it "leaves an export alone while a Solid Queue job still references it" do
    export = stalled_export(created_at: 3.hours.ago)
    allow(SolidQueue::Job).to receive(:where).and_return(
      instance_double(ActiveRecord::Relation, pluck: [%(["gid://bakecycle/FileExport/#{export.id}"])])
    )

    expect(described_class.new.perform).to eq(0)
    expect(export.reload.file).to be_blank
  end

  it "does not touch an export that finished successfully" do
    export = stalled_export(created_at: 3.hours.ago)
    export.update!(file: FakeFileIO.new("Report.csv", "a,b\n1,2\n"))
    original_name = export.file_file_name

    expect(described_class.new.perform).to eq(0)
    expect(export.reload.file_file_name).to eq(original_name)
  end
end
