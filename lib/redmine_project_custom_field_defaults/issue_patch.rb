module RedmineProjectCustomFieldDefaults
  # Excludes custom field values locked by a project default from the set of
  # editable values.
  #
  # Issue#editable_custom_field_values is the single choke point Redmine
  # itself uses for workflow-based read-only fields: issue forms only render
  # inputs for the fields it returns (app/views/issues/_form_custom_fields
  # .html.erb), and Issue#safe_attributes= filters incoming
  # custom_field_values against it before assignment. Rejecting locked
  # fields here therefore hides them from new/edit forms and blocks them
  # from being written server-side, exactly like a workflow-locked field.
  module IssuePatch
    def editable_custom_field_values(user = nil)
      super.reject { |value| RedmineProjectCustomFieldDefaults.locked_for?(value, project, user) }
    end
  end
end
