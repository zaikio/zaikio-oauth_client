module Zaikio
  module OAuthClient
    module Authenticatable # rubocop:disable Metrics/ModuleLength
      extend ActiveSupport::Concern

      def new
        opts = params.permit(:client_name, :show_signup, :prompt, :prompt_email_confirmation,
                             :force_login, :state, :lang,
                             person: %i[first_name name email],
                             organization: [:name, :country_code, { kinds: [] }])
        opts[:lang] ||= I18n.locale if defined?(I18n)
        client_name = opts.delete(:client_name)
        opts[:state] ||= session[:state] = SecureRandom.urlsafe_base64(32)

        redirect_to oauth_client.auth_code.authorize_url(
          redirect_uri: approve_url(client_name),
          scope: oauth_scope,
          **opts
        ), allow_other_host: true
      end

      def approve  # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        if params[:error].present?
          redirect_to send(
            respond_to?(:error_path_for) ? :error_path_for : :default_error_path_for,
            params[:error],
            description: params[:error_description]
          ) and return
        end

        if session[:state].present? && params[:state] != session[:state]
          return redirect_to send(
            respond_to?(:error_path_for) ? :error_path_for : :default_error_path_for,
            "invalid_state"
          )
        end

        access_token = create_access_token

        origin = session[:origin]
        session.delete(:origin)
        session.delete(:oauth_attempts)

        session[:zaikio_access_token_id] = access_token.id unless access_token.organization?

        redirect_to send(
          respond_to?(:after_approve_path_for) ? :after_approve_path_for : :default_after_approve_path_for,
          access_token, origin
        )
      rescue OAuth2::Error => e
        raise e unless e.code == "invalid_grant" || e.code == "invalid_request"
        raise e if session[:oauth_attempts].to_i >= 3

        session[:oauth_attempts] = session[:oauth_attempts].to_i + 1

        redirect_to new_path(client_name: params[:client_name])
      end

      def destroy
        if (access_token = Zaikio::AccessToken.valid.or(Zaikio::AccessToken.valid_refresh)
                                             .find_by(id: session[:zaikio_access_token_id]))
          access_token.revoke!
        end
        session.delete(:zaikio_access_token_id)
        session.delete(:origin)

        redirect_to send(
          respond_to?(:after_destroy_path_for) ? :after_destroy_path_for : :default_after_destroy_path_for,
          access_token&.id
        )
      end

      private

      def new_path(options = {})
        zaikio_oauth_client.new_session_path(options)
      end

      def approve_url(client_name = nil)
        zaikio_oauth_client.approve_session_url(client_name)
      end

      def use_org_config?
        false
      end

      def create_access_token
        access_token_response = oauth_client.auth_code.get_token(params[:code])

        Zaikio::AccessToken.build_from_access_token(
          access_token_response,
          requested_scopes: client_config.default_scopes
        ).tap(&:save!)
      end

      def client_name
        params[:client_name] || Zaikio::OAuthClient.configuration.all_client_names.first
      end

      def client_config
        client_config = Zaikio::OAuthClient.configuration.find!(client_name)
        client_config = client_config.org_config if use_org_config?

        client_config or raise ActiveRecord::RecordNotFound
      end

      def oauth_client
        Zaikio::OAuthClient.for(client_name)
      end

      def oauth_scope
        client_config.scopes_for_auth(params[:organization_id]).join(",")
      end

      def default_after_approve_path_for(access_token, origin)
        session[:zaikio_person_id] = access_token.bearer_id unless access_token.organization?

        origin || main_app.root_path
      end

      def default_after_destroy_path_for(_access_token_id)
        session.delete(:origin)

        main_app.root_path
      end

      def default_error_path_for(error_code, description: nil)
        raise Zaikio::OAuthClient::InvalidScopesError, description if error_code == "invalid_scope"

        unless error_code == "access_denied"
          flash[:alert] = I18n.t("zaikio.oauth_client.error_occured", error: error_code, description: description)
        end

        main_app.root_path
      end
    end
  end
end
