module Zaiku
  class Engine < ::Rails::Engine
    isolate_namespace Zaiku
    config.generators.api_only = true
  end
end
