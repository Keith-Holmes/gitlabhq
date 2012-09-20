require "base64"

class CommitsController < ApplicationController
  before_filter :project
  layout "project"

  include ExtractsPath

  # Authorize
  before_filter :add_project_abilities
  before_filter :authorize_read_project!
  before_filter :authorize_code_access!
  before_filter :require_non_empty_project

  def show
    @repo = @project.repo
    @limit, @offset = (params[:limit] || 40), (params[:offset] || 0)

    @commits = @project.commits(@ref, @path, @limit, @offset)
    @commits = CommitDecorator.decorate(@commits)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.atom { render layout: false }
    end
  end

  def patch
    @commit = project.commit(params[:id])

    send_data(
      @commit.to_patch,
      type: "text/plain",
      disposition: 'attachment',
      filename: "#{@commit.id}.patch"
    )
  end
end
