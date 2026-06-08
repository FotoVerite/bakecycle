# frozen_string_literal: true

class FileActionsController < ApplicationController
  def index
    authorize FileAction
    @file_actions = policy_scope(FileAction).where("created_at >= ?", Time.zone.today - 7.days).order(created_at: :desc)
  end
end
