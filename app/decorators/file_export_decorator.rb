class FileExportDecorator < Draper::Decorator
  delegate_all

  def loading_message
    LoadingMessages.sample
  end

  def serializable_hash
    FileExportSerializer.new(object).serializable_hash
      .transform_keys { |k| k.to_s.camelize(:lower) }
  end
end
