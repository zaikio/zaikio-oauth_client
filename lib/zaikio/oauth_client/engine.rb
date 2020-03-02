module Zaikio
  module OAuthClient
    class Engine < ::Rails::Engine
      isolate_namespace Zaikio::OAuthClient
      engine_name "zaikio_oauth_client"
      config.generators.api_only = true
    end
  end
end
