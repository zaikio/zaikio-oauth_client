class EncryptTokens < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        rename_column :zaikio_access_tokens, :token, :unencrypted_token
        rename_column :zaikio_access_tokens, :refresh_token, :unencrypted_refresh_token

        add_column :zaikio_access_tokens, :token, :string
        add_column :zaikio_access_tokens, :refresh_token, :string

        Zaikio::AccessToken.find_each do |access_token|
          access_token.update(
            token: access_token.unencrypted_token,
            refresh_token: access_token.unencrypted_refresh_token
          )
        end

        change_column_null :zaikio_access_tokens, :token, false

        remove_column :zaikio_access_tokens, :unencrypted_token, :string
        remove_column :zaikio_access_tokens, :unencrypted_refresh_token, :string
      end

      dir.down do
        add_column :zaikio_access_tokens, :unencrypted_token, :string
        add_column :zaikio_access_tokens, :unencrypted_refresh_token, :string

        Zaikio::AccessToken.find_each do |access_token|
          access_token.update_columns(
            unencrypted_token: access_token.token,
            unencrypted_refresh_token: access_token.refresh_token
          )
        end

        remove_column :zaikio_access_tokens, :token, :string
        remove_column :zaikio_access_tokens, :refresh_token, :string

        rename_column :zaikio_access_tokens, :unencrypted_token, :token
        rename_column :zaikio_access_tokens, :unencrypted_refresh_token, :refresh_token

        change_column_null :zaikio_access_tokens, :token, false
      end
    end
  end
end
