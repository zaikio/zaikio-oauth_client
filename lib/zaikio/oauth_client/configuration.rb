require "logger"
require "zaikio/oauth_client/client_configuration"

module Zaikio
  module OAuthClient
    class Configuration
      HOSTS = {
        development: "http://hub.zaikio.test",
        test: "http://hub.zaikio.test",
        staging: "https://hub.staging.zaikio.com",
        sandbox: "https://hub.sandbox.zaikio.com",
        production: "https://hub.zaikio.com"
      }.freeze

      attr_accessor :host
      attr_writer :logger
      attr_reader :client_configurations, :environment, :around_auth_block,
                  :sessions_controller_name, :connections_controller_name, :subscriptions_controller_name

      def initialize
        @client_configurations = {}
        @around_auth_block = nil
        @sessions_controller_name = "sessions"
        @connections_controller_name = "connections"
        @subscriptions_controller_name = "subscriptions"
      end

      def logger
        @logger ||= Logger.new($stdout)
      end

      def register_client(name)
        @client_configurations[name.to_s] ||= ClientConfiguration.new(name.to_s)
        yield(@client_configurations[name.to_s])
      end

      def find!(name)
        @client_configurations[name.to_s] or raise ActiveRecord::RecordNotFound
      end

      def all_client_names
        client_configurations.keys
      end

      def environment=(env)
        @environment = env.to_sym
        @host = host_for(environment)
      end

      def around_auth(&block)
        @around_auth_block = block
      end

      def sessions_controller_name=(name)
        @sessions_controller_name = "/#{name}"
      end

      def connections_controller_name=(name)
        @connections_controller_name = "/#{name}"
      end

      def subscriptions_controller_name=(name)
        @subscriptions_controller_name = "/#{name}"
      end

      private

      def host_for(environment)
        HOSTS.fetch(environment) do
          raise StandardError.new, "Invalid Zaikio::OAuthClient environment '#{environment}'"
        end
      end
    end
  end
end
