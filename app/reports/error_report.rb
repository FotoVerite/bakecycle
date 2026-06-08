# frozen_string_literal: true

class ErrorReport < BasePdfReport
  def initialize(error)
    @error = error
    super()
  end

  def setup
    text "IF YOU SEE THIS PLEASE CONTACT matthew.z.bergman@gmail.com IMMEDIATELY WITH THIS ATTACHED"
    move_down 20
    text @error.message
    text @error.backtrace.join "\n"
  end
end
