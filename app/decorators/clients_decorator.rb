class ClientsDecorator < Draper::CollectionDecorator
  def to_json
    {
      data: object.map { |client| ClientSerializer.new(client) }
    }
  end
end
