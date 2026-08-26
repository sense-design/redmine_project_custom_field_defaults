class CreateProjectCustomFieldDefaults < ActiveRecord::Migration[7.0]
  def change
    create_table :project_custom_field_defaults do |t|
      t.references :project, null: false
      t.references :custom_field, null: false
      t.text :value
      t.timestamps
    end

    add_index :project_custom_field_defaults,
              [:project_id, :custom_field_id],
              unique: true,
              name: 'index_pcfd_on_project_and_custom_field'
  end
end