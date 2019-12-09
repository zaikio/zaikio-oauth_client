module Zaiku
  module VueHelper
    def vue_component(component, props = {})
      tag.div data: { controller: :vue, component: component, props: props }
    end
  end
end
