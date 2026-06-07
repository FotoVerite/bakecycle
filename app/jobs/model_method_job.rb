class ModelMethodJob < ApplicationJob
  queue_as :default

  def perform(class_name, id, method, *args)
    class_name.constantize.find(id).public_send(method, *args)
  end
end
