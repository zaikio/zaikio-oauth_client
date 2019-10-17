class CreateZaikuOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :zaiku_organizations, type: :uuid do |t|
      t.string :type, index: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
