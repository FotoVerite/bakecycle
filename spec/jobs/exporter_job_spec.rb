require 'rails_helper'
describe ExporterJob do
  describe '#create' do
    it 'creates a file export object and enqueues itself' do
      bakery = create(:bakery)
      generator = PackingSlipsGenerator.new(bakery, Time.zone.today, true)
      export = nil
      expect { export = ExporterJob.create(bakery, generator) }.to enqueue_a(ExporterJob)
      expect(export).to be_persisted
    end

    it 'generates the report and stores it on the export' do
      bakery = create(:bakery)
      generator = PackingSlipsGenerator.new(bakery, Time.zone.today, true)
      export = FileExport.create!(bakery: bakery)
      ExporterJob.new.perform(export, generator)
      export.reload
      expect(export.file).to be_present
    end
  end
end
