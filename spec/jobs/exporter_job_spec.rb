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

    it "reports the generator's failure to Sentry, not just the error-report PDF" do
      export = FileExport.create!(bakery: bakery, user: user)
      failing_generator = instance_double(PackingSlipsGenerator, filename: "packing-slips", generate: nil)
      boom = StandardError.new("boom")
      allow(failing_generator).to receive(:generate).and_raise(boom)

      expect(Sentry).to receive(:capture_exception).with(boom)

      ExporterJob.new.perform(user, export, failing_generator)
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

    it "reports to Sentry even when no FileExport argument can be resolved to attach an error to" do
      # Corrupting the FileExport's own GlobalID (rather than the generator's,
      # as above) means locate_file_export_from_raw_arguments can't find
      # anything to mark errored -- before Sentry reporting was added here,
      # this exact failure mode was completely silent.
      export = FileExport.create!(bakery: bakery, user: user)
      job = ExporterJob.new(user, export, generator)
      serialized = job.serialize
      serialized["arguments"][1]["_aj_globalid"] = "gid://bakecycle/FileExport/999999999"

      expect(Sentry).to receive(:capture_exception)

      ExporterJob.execute(serialized)

      expect(export.reload).to_not be_failed
    end

    it "tags the current span with file export and tenant identity" do
      # Exercised directly (bypassing perform/generate) rather than stubbing
      # OpenTelemetry::Trace.current_span for a full job run -- ActiveJob's
      # own OTel instrumentation calls current_span internally too, and an
      # instance_double only responds to the methods it's given, so a global
      # stub here would raise on the first unrelated call it doesn't expect.
      export = FileExport.create!(bakery: bakery, user: user)
      span = instance_double(OpenTelemetry::Trace::Span)
      allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)

      expect(span).to receive(:add_attributes).with(
        "file_export.id" => export.id,
        "bakery.id" => bakery.id.to_s,
        "file_export.user_id" => user.id
      )

      ExporterJob.new.send(:tag_current_span, export)
    end
  end
end
