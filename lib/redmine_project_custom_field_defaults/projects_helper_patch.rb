module RedmineProjectCustomFieldDefaults
  # Appends the defaults tab to the project settings.
  #
  # Redmine filters its own tab list by permission before returning it, so the
  # permission check has to be repeated here for the appended entry.
  module ProjectsHelperPatch
    def project_settings_tabs
      tabs = super

      return tabs unless User.current.allowed_to?(:edit_project, @project)

      tabs << {
        name:    'custom_field_defaults',
        action:  :edit_project,
        partial: 'projects/settings/custom_field_defaults',
        label:   :label_custom_field_defaults
      }

      tabs
    end
  end
end