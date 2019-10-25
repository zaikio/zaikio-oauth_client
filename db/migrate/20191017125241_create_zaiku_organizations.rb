class CreateZaikuOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :zaiku_organizations, id: :uuid do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
