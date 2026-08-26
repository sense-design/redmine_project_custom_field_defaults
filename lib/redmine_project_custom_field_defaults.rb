# Namespace module for the plugin.
#
# Redmine adds every plugin's lib directory to the Zeitwerk autoload paths,
# so files below lib/redmine_project_custom_field_defaults/ must follow the
# standard constant naming convention.
module RedmineProjectCustomFieldDefaults
  # Checks a stored default against the target field's own validation.
  #
  # This is used as a safety net when the value is applied to a new issue: if
  # the configuration of a custom field changed after the default was stored
  # (a list value was removed, a regexp was tightened), the default is dropped
  # instead of making the issue unsavable.
  def self.acceptable?(custom_field, value, customized)
    probe  = CustomValue.new(customized: customized, custom_field: custom_field, value: value)
    errors = custom_field.validate_custom_value(probe)

    return true if errors.blank?

    Rails.logger.info(
      "[redmine_project_custom_field_defaults] Ignoring stored default #{value.inspect} " \
        "for custom field ##{custom_field.id}: #{errors.join(', ')}"
    )
    false
  end
end