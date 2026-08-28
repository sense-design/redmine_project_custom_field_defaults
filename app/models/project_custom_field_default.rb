# Stores the default value of a single issue custom field for a single project.
#
# A missing row means "inherit from the parent project"; a row with a blank
# value is never written, so clearing the input in the settings form removes
# the row and restores inheritance.
#
# A row can also be locked: while locked, the field can no longer be changed
# on issues of this project (or its subprojects, as long as they don't
# define their own row), unless the user holds the
# :override_locked_project_custom_field_defaults permission. See
# RedmineProjectCustomFieldDefaults.locked_for? and IssuePatch.
class ProjectCustomFieldDefault < ApplicationRecord
  belongs_to :project
  belongs_to :custom_field

  validates :custom_field_id, uniqueness: {scope: :project_id}
  validate :value_must_be_valid_for_custom_field
  validate :locked_requires_value

  # Replaces all defaults of a project in one transaction.
  #
  # Expects a hash of custom field id => value and a hash of custom field id
  # => lock flag, both as submitted by the settings form. Returns an array
  # of error messages; if it is not empty, nothing has been written.
  def self.replace_for(project, submitted, locked = {})
    records  = []
    messages = []
    bool_type = ActiveModel::Type::Boolean.new

    (submitted.keys | locked.keys).each do |custom_field_id|
      raw_value = submitted[custom_field_id]
      value     = raw_value.is_a?(Array) ? raw_value.reject(&:blank?).first : raw_value
      is_locked = bool_type.cast(locked[custom_field_id]) || false

      # A blank, unlocked field simply has nothing to store.
      next if value.blank? && !is_locked

      record = new(project: project, custom_field_id: custom_field_id.to_i, value: value.to_s, locked: is_locked)

      if record.valid?
        records << record
      else
        label = record.custom_field&.name || custom_field_id
        messages << "#{label}: #{record.errors.full_messages.join(', ')}"
      end
    end

    return messages if messages.any?

    transaction do
      where(project_id: project.id).delete_all
      records.each(&:save!)
    end

    []
  end

  private

  def value_must_be_valid_for_custom_field
    return if value.blank? || custom_field.nil? || project.nil?

    probe = CustomValue.new(
      customized:   Issue.new(project: project),
      custom_field: custom_field,
      value:        value
    )

    custom_field.validate_custom_value(probe).each do |message|
      errors.add(:value, message)
    end
  end

  def locked_requires_value
    errors.add(:base, l(:text_custom_field_default_locked_requires_value)) if locked? && value.blank?
  end
end
