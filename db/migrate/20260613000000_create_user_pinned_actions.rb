# frozen_string_literal: true

class CreateUserPinnedActions < ActiveRecord::Migration[8.1]
  def change
    create_table :user_pinned_actions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_key, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :user_pinned_actions, %i[user_id action_key], unique: true
    add_index :user_pinned_actions, %i[user_id position]
  end
end
