class StaticPagesController < ApplicationController
  def index
    active_nav(:dashboard)
  end
end
