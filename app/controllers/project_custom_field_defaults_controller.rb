class ProjectCustomFieldDefaultsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize_defaults

  def update
    payload   = params.fetch(:defaults, {}).permit!.to_h
    submitted = payload.fetch('custom_field_values', {})
    locked    = payload.fetch('locked', {})
    messages  = ProjectCustomFieldDefault.replace_for(@project, submitted, locked)

    if messages.empty?
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = messages.join('<br>').html_safe
    end

    redirect_to settings_project_path(@project, tab: 'custom_field_defaults')
  end

  private

  # The tab is bound to the standard project administration permission, which
  # avoids having to touch role configuration on an existing installation.
  def authorize_defaults
    deny_access unless User.current.allowed_to?(:edit_project, @project)
  end
end