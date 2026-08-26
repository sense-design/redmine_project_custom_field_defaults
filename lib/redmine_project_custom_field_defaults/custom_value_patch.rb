module RedmineProjectCustomFieldDefaults
  # Prefills the value when a custom value is built for a new issue.
  #
  # Redmine runs set_default_value as an after_initialize callback. At that
  # point the issue and its project are already assigned, which makes this the
  # natural place to inject a project specific default.
  #
  # The value is only ever written when the field is still blank, and calling
  # super afterwards keeps the global default of the custom field as the last
  # fallback. Nothing here touches existing issues: the guard requires both the
  # custom value and its customized object to be new records.
  module CustomValuePatch
    private

    def set_default_value
      if new_record? && custom_field && value.blank? &&
         (customized.nil? || customized.new_record?)
        apply_project_default
      end

      super
    end

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