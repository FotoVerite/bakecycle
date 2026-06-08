# frozen_string_literal: true

class FileExportDecorator < Draper::Decorator
  delegate_all

  def loading_message
    LoadingMessages.sample
  end

end
