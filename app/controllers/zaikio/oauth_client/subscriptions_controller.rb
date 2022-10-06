module Zaikio
  module OAuthClient
    class SubscriptionsController < ConnectionsController
      def new  # rubocop:disable Metrics/MethodLength
        opts = params.permit(:client_name, :state, :plan, :organization_id, :app_name, :redirect_uri)
        opts[:state] ||= session[:state] = SecureRandom.urlsafe_base64(32)

        plan            = opts.delete(:plan)
        organization_id = opts.delete(:organization_id)
        app_name        = opts.delete(:app_name)
        redirect_uri    = opts.delete(:redirect_uri)

        scope = "Org.subscription_create"
        scope_with_org_id = "Org/#{organization_id}.subscription_create"
        subscription_scope = if app_name.present?
                               organization_id.present? ? "#{scope_with_org_id}_#{app_name}" : "#{scope}_#{app_name}"
                             else
                               organization_id.present? ? scope_with_org_id : scope
                             end

        subscription_scope << ".#{plan}" if plan.present?

        redirect_to oauth_client.auth_code.authorize_url(
          redirect_uri: redirect_uri || approve_url(opts.delete(:client_name)),
          scope: subscription_scope,
          **opts
        ), allow_other_host: true
      end
    end
  end
end
