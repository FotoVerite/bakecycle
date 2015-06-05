module ResqueJobs
  extend ActiveSupport::Concern

  class_methods do
    def queue
      model_name.route_key.to_sym
    end

    def perform(id, method, *args)
      find(id).public_send(method, *args)
    end
  end

  def async(method, *args)
    Resque.enqueue(self.class, id, method, *args)
  end
end
