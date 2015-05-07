module Denormalization
  extend ActiveSupport::Concern

  class_methods do
    def denormalize(object_name, fields)
      define_id_method(object_name)
      define_obj_method(object_name, fields)
    end

    def define_id_method(object_name)
      define_method "#{object_name}_id=" do |object_id|
        object_changed = send(:"#{object_name}_id") != object_id
        if object_changed
          object = object_name.to_s.classify.constantize.find_by(id: object_id)
          send(:"#{object_name}=", object)
        end
        object_id
      end
    end

    def define_obj_method(object_name, fields)
      define_method "#{object_name}=" do |object|
        object ||= OpenStruct.new
        fields.each do |field|
          parent_field = "#{object_name}_#{field}".to_sym
          value = object.send(field)
          self[parent_field] = value
        end
        object
      end
    end
  end
end
