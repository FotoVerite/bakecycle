class FileExportDecorator < Draper::Decorator
  delegate_all

  def to_json
    FileExportSerializer.new(object).to_json
  end
end
