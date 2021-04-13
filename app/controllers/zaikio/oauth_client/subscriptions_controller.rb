module Zaikio
  module OAuthClient
    class SubscriptionsController < ConnectionsController
      def new
        opts = params.permit(:client_name, :state, :plan)
        client_name = opts.delete(:client_name)
        plan = opts.delete(:plan)

        subscription_scope = "Org.subscription_create"
        subscription_scope << ".#{plan}" if plan.present?

        redirect_to oauth_client.auth_code.authorize_url(
          redirect_uri: approve_url(client_name),
          scope: subscription_scope,
          **opts
        )
      end
    end
  end
end
