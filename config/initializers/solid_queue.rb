# frozen_string_literal: true

Rails.application.config.active_job.queue_adapter = :solid_queue

MissionControl::Jobs.http_basic_auth_enabled = false
