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
    file_export.file = file
    file_export.file_content_type = generator.content_type if generator.respond_to?(:content_type)
    file_export.save!
  rescue Resque::TermException
    Resque.logger.error "Resque job termination re-queuing #{self} #{file_export}, #{generator}"
    self.class.perform_later(file_export, generator)
  end
end
