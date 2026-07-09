# frozen_string_literal: true

class AddUserToFileExports < ActiveRecord::Migration[8.1]
  def up
    add_column :file_exports, :user_id, :integer
    add_index :file_exports, :user_id

    # Backfill ownership from the FileAction audit trail: the person who created
    # each export is recorded as its earliest action == "created" row. This keeps
    # everyone's existing export history visible under the new per-user scoping
    # instead of orphaning every pre-existing export.
    execute(<<~SQL.squish)
      UPDATE file_exports fe
      SET user_id = fa.user_id
      FROM (
        SELECT DISTINCT ON (file_export_id) file_export_id, user_id
        FROM file_actions
        WHERE action = 'created' AND user_id IS NOT NULL
        ORDER BY file_export_id, created_at ASC
      ) fa
      WHERE fa.file_export_id = fe.id
    SQL
  end

  def down
    remove_column :file_exports, :user_id
  end
end
