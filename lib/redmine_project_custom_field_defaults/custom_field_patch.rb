module RedmineProjectCustomFieldDefaults
  # Removes stored defaults when the custom field itself is deleted, so no
  # orphaned rows are left behind.
  module CustomFieldPatch
    def self.prepended(base)
      base.class_eval do
        after_destroy :destroy_project_custom_field_defaults
      end
    end

    private

    def destroy_project_custom_field_defaults
      ProjectCustomFieldDefault.where(custom_field_id: id).delete_all
    end
  end
end