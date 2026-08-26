require 'redmine'

Redmine::Plugin.register :redmine_project_custom_field_defaults do
  name 'Project Custom Field Defaults'
  author 'Sven Culley'
  description 'Per project default values for issue custom fields, inherited along the project tree and freely overridable on the issue.'
  version '1.0.1'
  url 'https://github.com/sense-design/redmine_project_custom_field_defaults'
  author_url 'https://www.linkedin.com/in/sven-culley'
  requires_redmine version_or_higher: '6.0.0'
end

RedmineProjectCustomFieldDefaults.apply_patches

Rails.application.config.to_prepare do
  RedmineProjectCustomFieldDefaults.apply_patches
end