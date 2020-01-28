class ElementsController < ApplicationController
  def index
    flash[:notice] = "This is a flash notice"
    # flash[:alert] = "This is a flash alert"
    @operators = Operator.all
      .search_by(params.dig(:keywords))
      .filter_by(params.dig(:filters))
      .sorted_by(params.dig(:sorting))
  end

  def autocomplete
    render json: Zaikio::Person.all.map { |e| { id: e.id, name: e.first_name, description: e.email } }
  end
end
