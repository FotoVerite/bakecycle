class BatchRunPdf < ProductionRunPdf
  def run_label
    "Production Run BATCH PROJECTION"
  end

  def production_run_info
    font_size 10
    text run_label
    text "Batch Dates: #{@run_data.start_date} - #{@run_data.batch_end_date.strftime('%A %B %e, %Y')}"
  end
end
