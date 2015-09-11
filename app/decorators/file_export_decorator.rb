class FileExportDecorator < Draper::Decorator
  delegate_all

  def serializable_hash
    FileExportSerializer.new(object).serializable_hash
  end
end
