class AddRequestedScopesToZaikioAccessTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :zaikio_access_tokens, :requested_scopes, :string, array: true, default: [], null: false
    Zaikio::AccessToken.update_all("requested_scopes = scopes, updated_at = now()")
  end
end
