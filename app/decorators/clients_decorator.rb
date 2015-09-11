class ClientsDecorator < Draper::CollectionDecorator
  def serializable_hash
    { data: map(&:serializable_hash) }
  end
end
