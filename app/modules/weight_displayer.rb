module WeightDisplayer
  SIG_FIGS = 3

  def display_weight(weight)
    weight_in_kgs = Unitwise(weight, :kg)

    if weight_in_kgs > Unitwise(1, :kg)
      weight_in_kgs.round(SIG_FIGS).to_s(:symbol)
    else
      weight_in_kgs.convert_to(:gram).round(SIG_FIGS).to_s(:symbol)
    end
  end
end
