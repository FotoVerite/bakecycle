# frozen_string_literal: true

module AsyncJobs
  extend ActiveSupport::Concern

  def async(method, *args)
    ModelMethodJob.perform_later(self.class.name, id, method.to_s, *args)
  end
end
