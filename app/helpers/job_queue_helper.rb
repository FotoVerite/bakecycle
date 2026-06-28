# frozen_string_literal: true

module JobQueueHelper
  def active_solid_queue_workers
    SolidQueue::Process
      .where(kind: "Worker")
      .where(last_heartbeat_at: SolidQueue.process_alive_threshold.ago..)
      .count
  end

  def active_solid_queue_processes
    SolidQueue::Process
      .where(last_heartbeat_at: SolidQueue.process_alive_threshold.ago..)
      .count
  end

  def pending_solid_queue_jobs
    SolidQueue::Job.where(finished_at: nil).count
  end

  def failed_solid_queue_jobs
    SolidQueue::FailedExecution.count
  end

  def completed_solid_queue_jobs
    SolidQueue::Job.where.not(finished_at: nil).count
  end
end
