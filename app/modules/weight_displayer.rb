module WeightDisplayer
  SIG_FIGS = 3

  # rubocop:disable Metrics/MethodLength
  def display_weight(weight, display_weight_in_kg = true)
    weight_in_kgs = Unitwise(weight, :kg)
    if display_weight_in_kg
      # Old way, will figure out a way to give a boolean
      if weight_in_kgs > Unitwise(0.001, :kg) || weight_in_kgs == Unitwise(0, :kg)
        {
          content: sprintf("%0.#{SIG_FIGS}f", weight_in_kgs.round(SIG_FIGS)),
          background_color: "ffffff"
        }
      else
        {
          content: sprintf("%0.#{SIG_FIGS}f", weight_in_kgs.convert_to(:gram).round(SIG_FIGS)),
          background_color: "d3d3d3"
        }
      end
    else
      {
        content: sprintf("%0.#{SIG_FIGS}f", weight_in_kgs.convert_to(:gram).round(SIG_FIGS)),
        background_color: "ffffff"
      }
    end
  end
end
