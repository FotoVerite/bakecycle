module WeightDisplayer
  require 'unitwise/ext'
  SIG_FIGS = 3

  def display_weight(weight)
    weight_in_kgs = Unitwise(weight, 'kilogram')

    if weight_in_kgs > 1.kilogram
      weight_in_kgs.round(SIG_FIGS).to_s(:symbol)
    else
      weight_in_kgs.convert_to('gram').round(SIG_FIGS).to_s(:symbol)
    end
  end
end
