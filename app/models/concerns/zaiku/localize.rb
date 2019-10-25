module Zaiku::Localize
  extend ActiveSupport::Concern

  # Generates a method when included called to_local_<class name>. The local class
  # must have the same name as the remote class. This method will also copy over all
  # locally known attributes from the remote class. Please note that the local class
  # needs to be an ActiveRecord::Base decendant
  included do |klass|
    define_method("to_local_#{klass.name.demodulize.downcase}") do
      local_klass = "Zaiku::#{klass.name.demodulize}".constantize
      local_attributes = local_klass.column_names

      local_object = local_klass.find_or_initialize_by(id: self.id)
      local_object.attributes = attributes.slice(*local_attributes)

      return local_object
    end
  end
end
