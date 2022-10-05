module Zaikio
  module OAuthClient
    class SubscriptionsController < ConnectionsController
      def new
        opts = params.permit(:client_name, :state, :plan, :organization_id, :app_name)
        opts[:state] ||= session[:state] = SecureRandom.urlsafe_base64(32)

        plan            = opts.delete(:plan)
        organization_id = opts.delete(:organization_id)

        subscription_scope = if organization_id.present?
                               return "Org/#{organization_id}.subscription_create_#{app_name}" if app_name.present?

                               "Org/#{organization_id}.subscription_create"
                             else
                               return "Org.subscription_create_#{app_name}" if app_name.present?

                               "Org.subscription_create"
                             end

        subscription_scope << ".#{plan}" if plan.present?

        redirect_to oauth_client.auth_code.authorize_url(
          redirect_uri: approve_url(opts.delete(:client_name)),
          scope: subscription_scope,
          **opts
        ), allow_other_host: true
      end
    end
  end
end
