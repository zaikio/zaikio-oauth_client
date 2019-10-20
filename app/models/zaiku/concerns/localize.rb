module Zaiku::Localize
  extend ActiveSupport::Concern

  included do |klass|
    define_method("to_#{klass.to_s}") do
      local_klass = "Zaiku::#{klass.to_s}".constantize
      @local_object ||= local_klass.new(attributes)
    end
  end
end
