module RedmineProjectCustomFieldDefaults
  # Prefills the value when a custom value is built for a new issue.
  #
  # Overrides initialize directly instead of hooking into an
  # after_initialize callback: on Redmine 7, CustomValue no longer
  # registers set_default_value (or any other method) as an
  # after_initialize/after_find callback, so patching that method has no
  # effect there. initialize is always invoked for `.new`, regardless of
  # what Rails' callback registry looks like in a given version, and is
  # never called when an existing row is loaded from the database (Rails
  # uses instantiate for that), so existing issues stay untouched exactly
  # as before.
  module CustomValuePatch
    def initialize(*args, &block)
      super

      if new_record? && custom_field && value.blank? &&
         (customized.nil? || customized.new_record?)
        apply_project_default
      end
    end

    private

    def apply_project_default
      return unless custom_field.is_a?(IssueCustomField)
      return unless customized.respond_to?(:project)

      project = customized.project
      return if project.nil?

      default = project.custom_field_default_value(custom_field)
      return if default.blank?

      self.value = default if RedmineProjectCustomFieldDefaults.acceptable?(custom_field, default, customized)
    end
  end
end
