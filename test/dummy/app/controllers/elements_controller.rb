class ElementsController < ApplicationController
  def index
    flash[:notice] = "This is a flash notice"
    # flash[:alert] = "This is a flash alert"
  end
end
