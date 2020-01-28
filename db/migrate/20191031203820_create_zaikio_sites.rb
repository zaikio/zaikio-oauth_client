class CreateioSites < ActiveRecord::Migration[6.0]
  def change
    create_table :zaikio_sites, id: :uuid do |t|
      t.references :organization, null: false, index: true, type: :uuid, foreign_key: { to_table: :zaikio_organizations }
      t.string :name, null: false
      t.timestamps
    end
  end
end
