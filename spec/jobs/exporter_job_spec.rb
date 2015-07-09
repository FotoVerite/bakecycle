require 'rails_helper'
describe ExporterJob do
  let(:bakery) { create(:bakery) }
  let(:generator) { PackingSlipsGenerator.new(bakery, Time.zone.today, true) }
  describe '.create' do
    it 'creates a file export object and enqueues itself' do
      export = nil
      expect { export = ExporterJob.create(bakery, generator) }.to enqueue_a(ExporterJob)
      expect(export).to be_persisted
    end
  end

  describe '#perform' do
    it 'generates the report and stores it on the export' do
      export = FileExport.create!(bakery: bakery)
      ExporterJob.new.perform(export, generator)
      export.reload
      expect(export.file).to be_present
    end

    it 'is idempotent' do
      export = FileExport.create!(bakery: bakery)
      ExporterJob.new.perform(export, generator)
      export_2 = FileExport.find(export.id)
      ExporterJob.new.perform(export_2, generator)
      expect(export_2).to_not be_changed
      expect(export).to eq(export_2)
    end

    it 're-enqueues itself when terminated' do
      export = FileExport.create!(bakery: bakery)
      expect(export).to receive(:update!).and_raise(Resque::TermException, 'TERM')
      expect { ExporterJob.new.perform(export, generator) }.to enqueue_a(ExporterJob)
    end
  end
end
