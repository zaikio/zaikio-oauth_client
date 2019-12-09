class ElementsController < ApplicationController
  def index
    flash[:notice] = "This is a flash notice"
    # flash[:alert] = "This is a flash alert"
  end

  def autocomplete
    render json: Zaiku::Person.all.map { |e| { id: e.id, name: e.first_name, description: e.email } }
  end
end
