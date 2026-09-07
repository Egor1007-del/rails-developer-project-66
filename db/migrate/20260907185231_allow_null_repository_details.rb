class AllowNullRepositoryDetails < ActiveRecord::Migration[8.1]
  def change
    change_column_null :repositories, :name, true
    change_column_null :repositories, :full_name, true
    change_column_null :repositories, :language, true
    change_column_null :repositories, :clone_url, true
    change_column_null :repositories, :ssh_url, true
  end
end
