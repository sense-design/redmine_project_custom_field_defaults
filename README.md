# Redmine Project Custom Field Defaults

Redmine plugin that stores a default value per project for issue custom
fields. The value is filled into the form when a new issue is created and
can be freely overridden there at any time — there is no enforcement and
no change to existing issues.

## How it works

- Defaults are stored in a dedicated table
  (`project_custom_field_defaults`), not as a project custom field. Your
  existing field configuration stays untouched.
- **Blank value = inherit.** If a parent project sets a value and a
  subproject leaves the field blank, the parent's value applies. This
  keeps maintenance to a single place.
- The default is only ever applied when a new issue is created (and only
  while the field is still blank). Existing issues are never modified.
- Multi-value fields (`multiple?`) are hidden in the settings UI, since a
  single stored value can't represent a multi-selection.
- If a custom field's configuration changes later in a way that makes a
  stored default invalid (e.g. a list value was removed), the default is
  silently ignored instead of making the issue unsavable.

## Installation

```bash
cd /path/to/redmine
# place the plugin at plugins/redmine_project_custom_field_defaults
RAILS_ENV=production bundle exec rake redmine:plugins:migrate
touch tmp/restart.txt   # or restart Passenger/Puma
```

## Usage

1. Go to the project → **Settings** → **Default values**.
2. Enter a value for the desired issue fields and save.
3. In subprojects, only fill in the fields that should override the
   inherited value.

Permission: the tab is bound to the standard `edit_project` permission,
no additional role configuration is needed.

## Uninstallation

```bash
cd /path/to/redmine
RAILS_ENV=production bundle exec rake redmine:plugins:migrate NAME=redmine_project_custom_field_defaults VERSION=0
```

Then remove the plugin directory.

## Known limitation

If someone switches the project in an already-open new-issue form,
Redmine re-renders the form via AJAX and carries over the field values
already entered — the default value from the original project stays
visible instead of being replaced by the newly selected project's
default. This doesn't occur on the usual path (creating an issue from
within the project).

## Requirements

- Redmine 6.0 or higher
