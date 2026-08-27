class AddLatestCheckIndexToRepositoryChecks < ActiveRecord::Migration[8.1]
  def change
    add_index :repository_checks,
              [ :repository_id, :created_at ]
  end
end
