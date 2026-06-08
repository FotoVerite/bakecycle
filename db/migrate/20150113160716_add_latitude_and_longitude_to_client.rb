# frozen_string_literal: true

class AddLatitudeAndLongitudeToClient < ActiveRecord::Migration
  def change
    add_column :clients, :latitude, :float
    add_column :clients, :longitude, :float
  end
end
