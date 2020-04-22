module Zaikio
  module OAuthClient
    module Authenticatable
      extend ActiveSupport::Concern

      def new
        cookies.encrypted[:origin] = params[:origin]

        redirect_to oauth_client.auth_code.authorize_url(
          redirect_uri: approve_url(params[:client_name]),
          scope: oauth_scope
        )
      end

      def approve
        access_token = create_access_token

        origin = cookies.encrypted[:origin]
        cookies.delete :origin

        cookies.encrypted[:zaikio_access_token_id] = access_token.id unless access_token.organization?

        redirect_to send(
          respond_to?(:after_approve_path_for) ? :after_approve_path_for : :default_after_approve_path_for,
          access_token, origin
        )
      end

      def destroy
        access_token_id = cookies.encrypted[:zaikio_access_token_id]
        cookies.delete :zaikio_access_token_id

        redirect_to send(
          respond_to?(:after_destroy_path_for) ? :after_destroy_path_for : :default_after_destroy_path_for,
          access_token_id
        )
      end

      private

      def approve_url(client_name = nil)
        approve_session_url(client_name)
      end

      def use_org_config?
        false
      end

      def create_access_token
        access_token_response = oauth_client.auth_code.get_token(params[:code])

        access_token = Zaikio::AccessToken.build_from_access_token(access_token_response)
        access_token.save!

        access_token
      end

      def client_name
        params[:client_name] || Zaikio::OAuthClient.configuration.all_client_names.first
      end

      def client_config
        client_config = Zaikio::OAuthClient.configuration.find!(client_name)
        client_config = use_org_config? ? client_config.org_config : client_config

        client_config or raise ActiveRecord::RecordNotFound
      end

      def oauth_client
        Zaikio::OAuthClient.for(client_name)
      end

      def oauth_scope
        client_config.scopes_for_auth(params[:organization_id]).join(",")
      end

      def default_after_approve_path_for(access_token, origin)
        cookies.encrypted[:zaikio_person_id] = access_token.bearer_id unless access_token.organization?

        origin || main_app.root_path
      end

      def default_after_destroy_path_for(_access_token_id)
        cookies.delete :zaikio_person_id

        main_app.root_path
      end
    end
  end
end
