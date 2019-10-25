require_dependency "zaiku/application_controller"

module Zaiku
  class SessionsController < ApplicationController
    def new
      cookies.encrypted[:origin] = params[:origin]
      redirect_to Zaiku.oauth_client.auth_code.authorize_url(redirect_uri: approve_sessions_url)
    end

    def approve
      # Retrieve the remote access token
      access_token = Zaiku.oauth_client.auth_code.get_token(params[:code])

      # Get the remote person
      directoy = Zaiku.directoy(token: access_token.token)
      remote_person = directoy.person
      person = remote_person.to_local_person

      # Update the local database with person, organization, membership info
      person.save!

      # Save the current access token for further requests
      Zaiku::Remote::AccessToken.new(
        bearer: person,
        token: access_token
      ).to_local_access_token.save!

      redirect_to(cookies.encrypted[:origin] || '/')
      cookies.delete :origin
    end

    def destroy
      Current.user = nil
      cookies.delete :person_id

      redirect_to root_path
    end
  end
end
