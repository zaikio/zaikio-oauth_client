module Zaiku::Localize
  extend ActiveSupport::Concern

  included do |klass|
    define_method("to_#{klass.name.demodulize}") do
      local_klass = "Zaiku::#{klass.name.demodulize}".constantize
      @local_object ||= local_klass.new(attributes)
    end
  end
end
