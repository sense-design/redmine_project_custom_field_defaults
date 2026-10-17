class AddLockedToProjectCustomFieldDefaults < ActiveRecord::Migration[7.0]
  def change
    add_column :project_custom_field_defaults, :locked, :boolean, null: false, default: false
  end
end
