class ExporterJob < ActiveJob::Base
  queue_as :file_exporter

  def self.create(bakery, generator)
    FileExport.create!(bakery: bakery).tap do |file_export|
      perform_later(file_export, generator)
    end
  end

  def perform(file_export, generator)
    if file_export.file.blank?
      file = FakeFileIO.new(generator.filename, generator.generate)
      file_export.update!(file: file)
    else
      raise "FileExport #{file_export.id} already has a file attached."
    end
  rescue Resque::TermException
    Resque.logger.error "Resque job termination re-queuing #{self} #{file_export}, #{generator}"
    self.class.perform_later(file_export, generator)
  end
end
