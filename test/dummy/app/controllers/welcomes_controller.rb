class WelcomesController < ApplicationController
  def index
    render plain: "Hello #{session[:zaikio_person_id]}"
  end
end
