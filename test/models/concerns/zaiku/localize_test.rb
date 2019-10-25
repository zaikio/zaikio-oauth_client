require 'test_helper'

module Zaiku
  class LocalizeTest < ActiveSupport::TestCase
    test "calling to_KLASSNAME makes a local object from a remote one" do
      remote_object = Zaiku::Remote::Person.new(nil, {
        first_name: 'Frank',
        name: 'Gallikanokus',
        email: 'fgalli@example.com'
      })

      local_object = remote_object.to_local_person
      
      assert_instance_of Zaiku::Person, local_object
      assert_equal remote_object.first_name, local_object.first_name
    end
  end
end
