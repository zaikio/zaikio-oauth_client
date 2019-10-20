require_dependency "zaiku/application_controller"
require 'oauth2'

module Zaiku
  class SessionsController < ApplicationController
    def new
      cookies.encrypted[:origin] = params[:origin]
      redirect_to oauth_client.auth_code.authorize_url(redirect_uri: approve_sessions_url)
    end

    def destroy
      Current.user = nil
      cookies.delete :person_id

      redirect_to root_path
    end

    def approve
      access_token = oauth_client.auth_code.get_token(params[:code])
      response = access_token.get('/api/v1/person')
      zaiku_data = JSON.parse(response.body)

      if person = Zaiku::Directory.person_class.find_or_create_from_zaiku(zaiku_data)
        person.save_access_token(access_token)

        Current.user = person
        cookies.encrypted[:person_id] = person.id
      end

      redirect_to(cookies.encrypted[:origin] || '/')
      cookies.delete :origin
    end

    private

    def oauth_client
      OAuth2::Client.new(
        Zaiku.client_id,
        Zaiku.client_secret,
        site: Zaiku.directory_url,
        authorize_url: 'oauth/authorize',
        token_url: 'oauth/access_token',
        connection_opts: { headers: { 'Accept': 'application/json' } }
      )
    end
  end
end
