module Zaikio
  class Engine < ::Rails::Engine
    isolate_namespace Zaikio
    config.generators.api_only = true
  end
end
