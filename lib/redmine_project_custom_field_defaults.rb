# Namespace module for the plugin.
#
# Redmine adds every plugin's lib directory to the Zeitwerk autoload paths,
# so files below lib/redmine_project_custom_field_defaults/ must follow the
# standard constant naming convention.
module RedmineProjectCustomFieldDefaults
  # Prepends the patches onto their target classes.
  #
  # Called both immediately when the plugin loads and from to_prepare: on
  # this install, other plugins' to_prepare callbacks apparently prevent
  # ours from ever running automatically, so the immediate call is what
  # actually makes the plugin work in production. to_prepare is kept as a
  # second attempt for development mode, where classes are reloaded between
  # requests. The included_modules guards make calling this twice harmless.
  def self.apply_patches
    unless Project.included_modules.include?(ProjectPatch)
      Project.prepend ProjectPatch
    end

    unless CustomField.included_modules.include?(CustomFieldPatch)
      CustomField.prepend CustomFieldPatch
    end

    unless CustomValue.included_modules.include?(CustomValuePatch)
      CustomValue.prepend CustomValuePatch
    end

    unless ProjectsHelper.included_modules.include?(ProjectsHelperPatch)
      ProjectsHelper.prepend ProjectsHelperPatch
    end
  end

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