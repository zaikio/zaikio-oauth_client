class EnhanceAccessTokenIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :zaikio_access_tokens, %i[bearer_type bearer_id]
    add_index :zaikio_access_tokens, %i[audience bearer_type bearer_id],
              name: :zaikio_access_tokens_lookup_index
  end
end
