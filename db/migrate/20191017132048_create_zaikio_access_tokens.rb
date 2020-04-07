class CreateZaikioAccessTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :zaikio_access_tokens, id: :uuid do |t|
      t.string :bearer_type, null: false, default: "Organization"
      t.string :bearer_id, null: false
      t.string :audience, null: false
      t.string :token, null: false, index: { unique: true }
      t.string :refresh_token, index: { unique: true }
      t.datetime :expires_at, index: true
      t.string :scopes, array: true, default: [], null: false
      t.timestamps
    end

    add_index :zaikio_access_tokens, %i[bearer_type bearer_id]
  end
end
