class SessionsController < ApplicationController
  def new
    redirect_to zaiku_directory.new_authorization_url(origin: params[:origin])
  end

  def destroy
    Current.user = nil
    cookies.delete :person_id

    redirect_to root_path
  end
end
