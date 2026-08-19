class CreateRepositoryChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :repository_checks do |t|
      t.references :repository, null: false, foreign_key: true
      t.string :commit_id
      t.string :aasm_state, null: false
      t.boolean :passed
      t.text :output

      t.timestamps
    end
  end
end
