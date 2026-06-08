# frozen_string_literal: true

class ExporterJob < ApplicationJob
  queue_as :file_exporter

  def self.create(user, bakery, generator)
    FileExport.create!(bakery: bakery).tap do |file_export|
      perform_later(user, file_export, generator)
    end
  end

  def perform(user, file_export, generator)
    if file_export.file.present?
      FileAction.create(user: user, bakery: user.bakery, file_export_id: file_export.id, action: "viewed")
    else
      create_file(user, file_export, generator)
    end
  end

  def create_file(user, file_export, generator)
    file = FakeFileIO.new(generator.filename, generator.generate)
    file_export.file = file
    file_export.file_content_type = generator.content_type if generator.respond_to?(:content_type)
    file_export.save!
    FileAction.create(user: user, bakery: user.bakery, file_export_id: file_export.id, action: "created")
  # This is a simple catch to deal with any issues arising from the PDF Generation
  rescue StandardError => e
    pdf = ErrorReport.new(e).render
    file = FakeFileIO.new("#{generator.filename}-error.pdf", pdf)
    file_export.file_content_type = "application/pdf"
    file_export.file = file
    file_export.save!
  end
end
