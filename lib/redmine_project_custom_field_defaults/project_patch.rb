module RedmineProjectCustomFieldDefaults
  # Adds the defaults association and the lookup that walks the project tree.
  module ProjectPatch
    def self.prepended(base)
      base.class_eval do
        has_many :custom_field_defaults,
                 class_name:  'ProjectCustomFieldDefault',
                 dependent:   :delete_all
      end
    end

    # Returns the default stored on this project itself, or nil.
    def own_custom_field_default(custom_field)
      custom_field_defaults.detect { |entry| entry.custom_field_id == custom_field.id }
    end

    # Returns the applicable default entry, which may belong to an ancestor.
    def effective_custom_field_default(custom_field)
      custom_field_default_index[custom_field.id]
    end

    # Returns the applicable default value as a String, or nil.
    def custom_field_default_value(custom_field)
      effective_custom_field_default(custom_field)&.value.presence
    end

    private

    # Loads the defaults of this project and all of its ancestors in a single
    # query and indexes them by custom field id. Ordering by lft ascending
    # means the root is processed first and deeper projects overwrite their
    # ancestors, so the nearest definition wins.
    def custom_field_default_index
      @custom_field_default_index ||= begin
                                        index = {}

                                        ProjectCustomFieldDefault
                                          .where(project_id: self_and_ancestors.ids)
                                          .includes(:project)
                                          .order(Arel.sql('projects.lft ASC'))
                                          .references(:project)
                                          .each { |entry| index[entry.custom_field_id] = entry }

                                        index
                                      end
    end
  end
end