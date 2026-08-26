require 'redmine'

Redmine::Plugin.register :redmine_project_custom_field_defaults do
  name        'Project Custom Field Defaults'
  author      'Sven'
  description 'Per project default values for issue custom fields, inherited along the project tree and freely overridable on the issue.'
  version     '1.0.0'
  url         'https://sense-design.de'
  requires_redmine version_or_higher: '6.0.0'
end

Rails.application.config.to_prepare do
  unless Project.included_modules.include?(RedmineProjectCustomFieldDefaults::ProjectPatch)
    Project.prepend RedmineProjectCustomFieldDefaults::ProjectPatch
  end

  unless CustomField.included_modules.include?(RedmineProjectCustomFieldDefaults::CustomFieldPatch)
    CustomField.prepend RedmineProjectCustomFieldDefaults::CustomFieldPatch
  end

  unless CustomValue.included_modules.include?(RedmineProjectCustomFieldDefaults::CustomValuePatch)
    CustomValue.prepend RedmineProjectCustomFieldDefaults::CustomValuePatch
  end

  unless ProjectsHelper.included_modules.include?(RedmineProjectCustomFieldDefaults::ProjectsHelperPatch)
    ProjectsHelper.prepend RedmineProjectCustomFieldDefaults::ProjectsHelperPatch
  end
end