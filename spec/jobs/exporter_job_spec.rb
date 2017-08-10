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
      export = FileExport.create!(bakery: bakery)
      ExporterJob.new.perform(user, export, generator)
      export.reload
      expect(export.file).to be_present
    end

    it "creates a papertrail of the user" do
      export = FileExport.create!(bakery: bakery)
      ExporterJob.new.perform(user, export, generator)
      file_action = FileAction.last
      expect(file_action).to_not be_nil
      expect(file_action.user).to eq(user)
      expect(file_action.bakery).to eq(bakery)
      expect(file_action.file_export).to eq(export)
      expect(file_action.action).to eq("created")
    end

    it "is idempotent" do
      export = FileExport.create!(bakery: bakery)
      ExporterJob.new.perform(user, export, generator)
      export2 = FileExport.find(export.id)
      ExporterJob.new.perform(user, export2, generator)
      expect(export2).to_not be_changed
      expect(export).to eq(export2)
    end

    it "creates a papertrail of the user viewing" do
      export = FileExport.create!(bakery: bakery)
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

    it "re-enqueues itself when terminated" do
      export = FileExport.create!(bakery: bakery)
      expect(export).to receive(:save!).and_raise(Resque::TermException, "TERM")
      expect { ExporterJob.new.perform(user, export, generator) }.to enqueue_a(ExporterJob)
    end
  end
end
