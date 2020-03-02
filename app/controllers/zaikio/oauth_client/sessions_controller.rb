require_dependency "zaikio/application_controller"

module Zaikio
  module OAuthClient
    class SessionsController < ApplicationController

      def new
        cookies.encrypted[:origin] = params[:origin]
        redirect_to Zaikio::OAuthClient.oauth_client.auth_code.authorize_url(
          redirect_uri: approve_sessions_url,
          scope: 'directory.person.r'
        )
      end

      def approve
        # Retrieve the remote access token
        access_token = Zaikio::OAuthClient.oauth_client.auth_code.get_token(params[:code])

        # Get the remote person
        directory = Zaikio::OAuthClient.directory(token: access_token.token)
        remote_person = directory.person

        # Transform the remote person into a local one, including all required
        # associations such as organization memberships and the organizations
        Current.user = person = remote_person.to_local_person_with_associations(directory)
        person.save!

        # Save the current access token for further requests, this also saves
        # the refresh token automatically
        Zaikio::Remote::AccessToken.initialize_by_oauth_access_token(
          access_token: access_token,
          bearer: person
        ).to_local_access_token.save!

        # Handle the cookies
        origin = cookies.encrypted[:origin]
        cookies.delete :origin
        cookies.encrypted[:zaikio_person_id] = person.id

        # Redirect the user back to the start
        redirect_to(origin || '/')
      end

      def destroy
        Current.user = nil
        cookies.delete :zaikio_person_id

        redirect_to main_app.root_path
      end
    end
  end
end
