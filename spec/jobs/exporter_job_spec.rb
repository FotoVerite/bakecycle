# frozen_string_literal: true

require "rails_helper"
describe ExporterJob do
  let(:bakery) { create(:bakery) }
  let(:user) { create(:user, bakery: bakery) }
  let(:generator) { PackingSlipsGenerator.new(bakery, Time.zone.today, true) }
  describe ".create" do
    it "creates a file export object and enqueues itself" do
      export = nil
      expect { export = ExporterJob.create(user, bakery, generator) }.to enqueue_a(ExporterJob)
      expect(export).to be_persisted
    end
  end

  describe "#perform" do
    it "generates the report and stores it on the export" do
      export = FileExport.create!(bakery: bakery, user: user)
      ExporterJob.new.perform(user, export, generator)
      export.reload
      expect(export.file).to be_present
    end

    it "creates a papertrail of the user" do
      export = FileExport.create!(bakery: bakery, user: user)
      ExporterJob.new.perform(user, export, generator)
      file_action = FileAction.last
      expect(file_action).to_not be_nil
      expect(file_action.user).to eq(user)
      expect(file_action.bakery).to eq(bakery)
      expect(file_action.file_export).to eq(export)
      expect(file_action.action).to eq("created")
    end

    it "is idempotent" do
      export = FileExport.create!(bakery: bakery, user: user)
      ExporterJob.new.perform(user, export, generator)
      export2 = FileExport.find(export.id)
      ExporterJob.new.perform(user, export2, generator)
      expect(export2).to_not be_changed
      expect(export).to eq(export2)
    end

    it "creates a papertrail of the user viewing" do
      export = FileExport.create!(bakery: bakery, user: user)
      ExporterJob.new.perform(user, export, generator)
      export2 = FileExport.find(export.id)
      ExporterJob.new.perform(user, export2, generator)
      file_action = FileAction.last
      expect(file_action).to_not be_nil
      expect(file_action.user).to eq(user)
      expect(file_action.bakery).to eq(bakery)
      expect(file_action.file_export).to eq(export)
      expect(file_action.action).to eq("viewed")
    end

    it "broadcasts a turbo stream replace for the tray and history row targets" do
      export = FileExport.create!(bakery: bakery, user: user)

      streams = capture_turbo_stream_broadcasts(FileExport.broadcast_stream_for(user)) do
        ExporterJob.new.perform(user, export, generator)
      end

      expect(streams.size).to eq(2)
      expect(streams.map { |s| s["target"] })
        .to contain_exactly("tray_file_export_#{export.id}", "file_export_#{export.id}")
      expect(streams.map { |s| s["action"] }).to all(eq("replace"))
    end

    it "still broadcasts when generation fails and falls back to an error report" do
      export = FileExport.create!(bakery: bakery, user: user)
      failing_generator = instance_double(PackingSlipsGenerator, filename: "packing-slips", generate: nil)
      allow(failing_generator).to receive(:generate).and_raise(StandardError, "boom")

      streams = capture_turbo_stream_broadcasts(FileExport.broadcast_stream_for(user)) do
        ExporterJob.new.perform(user, export, failing_generator)
      end

      expect(export.reload).to be_ready
      expect(export.reload).to be_failed
      expect(streams.size).to eq(2)
    end

    it "marks the file export as failed if a job argument fails to deserialize" do
      # perform's own rescue never runs here since ActiveJob raises trying to
      # resolve the corrupted GlobalID before perform is even called -- this
      # is what used to leave a FileExport stuck at "Generating..." forever.
      export = FileExport.create!(bakery: bakery, user: user)
      job = ExporterJob.new(user, export, generator)
      serialized = job.serialize
      serialized["arguments"][2]["_aj_globalid"] = "gid://bakecycle/PackingSlipsGenerator/nonexistent"

      streams = capture_turbo_stream_broadcasts(FileExport.broadcast_stream_for(user)) do
        ExporterJob.execute(serialized)
      end

      expect(export.reload).to be_failed
      expect(streams.size).to eq(2)
    end
  end
end
