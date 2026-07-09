# frozen_string_literal: true

class ExporterJob < ApplicationJob
  queue_as :file_exporter

  # Safety net for failures ActiveJob never lets `perform` run for at all --
  # most commonly a GlobalID argument failing to deserialize (e.g. a record
  # referenced by the generator was deleted mid-flight). `create_file`'s own
  # rescue below can't catch these since `perform` never starts, which used to
  # leave the FileExport stuck at "Generating..." forever (confirmed: this is
  # exactly how ~250 exports going back years ended up permanently stalled).
  rescue_from StandardError, with: :record_unexpected_failure

  def self.create(user, bakery, generator)
    FileExport.create!(bakery: bakery, user: user).tap do |file_export|
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
    broadcast_export_update(file_export)
  # This is a simple catch to deal with any issues arising from the PDF Generation
  rescue StandardError => e
    mark_errored(file_export, e)
  end

  private

  def mark_errored(file_export, exception)
    return if file_export.ready?

    pdf = ErrorReport.new(exception).render
    file_export.file_content_type = "application/pdf"
    file_export.file = FakeFileIO.new("export-error.pdf", pdf)
    file_export.save!
    broadcast_export_update(file_export)
  end

  def record_unexpected_failure(exception)
    file_export = locate_file_export_from_raw_arguments
    mark_errored(file_export, exception) if file_export
  end

  # ActiveJob only assigns the public `arguments` reader *after* the whole
  # array deserializes successfully -- if one argument's GlobalID fails to
  # resolve, `arguments` is still nil and the raw serialized hashes only
  # exist in the private @serialized_arguments ivar (no public reader for
  # it), which is why this reaches in directly rather than using `arguments`.
  def locate_file_export_from_raw_arguments
    raw = arguments.presence || instance_variable_get(:@serialized_arguments)
    Array(raw).each do |arg|
      return arg if arg.is_a?(FileExport)

      gid = arg.is_a?(Hash) ? (arg["_aj_globalid"] || arg[:_aj_globalid]) : nil
      return GlobalID::Locator.locate(gid) if gid.to_s.include?("/FileExport/")
    end
    nil
  rescue StandardError
    nil
  end

  # Broadcast twice: once for the header tray's row, once for the /file_exports
  # history page's row. Turbo silently no-ops a replace targeting a DOM id that
  # isn't present on the current page, so this is safe even though only one of
  # the two targets exists on any given page.
  def broadcast_export_update(file_export)
    Turbo::StreamsChannel.broadcast_replace_to(
      file_export.broadcast_stream,
      target: "tray_file_export_#{file_export.id}",
      partial: "file_exports/tray_item",
      locals: { file_export: file_export, variant: :flash }
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      file_export.broadcast_stream,
      target: "file_export_#{file_export.id}",
      partial: "file_exports/history_row",
      locals: { file_export: file_export, variant: :flash }
    )
  end
end
