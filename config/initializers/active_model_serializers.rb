ActiveModel::Serializer.root = false
ActiveModel::Serializer.setup do |config|
  config.key_format = :lower_camel
end
