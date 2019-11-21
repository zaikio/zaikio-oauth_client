# This migration comes from zaiku (originally 20190426155505)
class EnablePostgresExtensionsForUuids < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
