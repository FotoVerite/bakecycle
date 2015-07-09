module WeightDisplayer
  SIG_FIGS = 3

  def display_weight(weight)
    weight_in_kgs = Unitwise(weight, :kg)

    if weight_in_kgs > Unitwise(0.001, :kg) || weight_in_kgs == Unitwise(0, :kg)
      {
        content: weight_in_kgs.round(SIG_FIGS).to_s(:symbol),
        background_color: 'ffffff'
      }
    else
      {
        content: weight_in_kgs.convert_to(:gram).round(SIG_FIGS).to_s(:symbol),
        background_color: 'd3d3d3'
      }
    end
  end
end
