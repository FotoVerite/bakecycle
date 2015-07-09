class ExporterJob < ActiveJob::Base
  queue_as :file_exporter

  def self.create(bakery, generator)
    FileExport.create!(bakery: bakery).tap do |file_export|
      perform_later(file_export, generator)
    end
  end

  def perform(file_export, generator)
    return if file_export.file.present?
    file = FakeFileIO.new(generator.filename, generator.generate)
    file_export.update!(file: file)
  rescue Resque::TermException
    Resque.logger.error "Resque job termination re-queuing #{self} #{file_export}, #{generator}"
    self.class.perform_later(file_export, generator)
  end
end
