class CreateRepositories < ActiveRecord::Migration[8.1]
  def change
    create_table :repositories do |t|
      t.string :name, null: false
      t.bigint :github_id, null: false
      t.string :full_name, null: false
      t.string :language
      t.string :clone_url, null: false
      t.string :ssh_url, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :repositories, [ :github_id, :user_id ], unique: true
  end
end
