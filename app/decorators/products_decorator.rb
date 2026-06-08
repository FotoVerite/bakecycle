# frozen_string_literal: true

class ProductsDecorator < Draper::CollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages
end
