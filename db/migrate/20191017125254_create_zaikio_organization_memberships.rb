class CreateZaikioOrganizationMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :zaikio_organization_memberships, id: :uuid do |t|
      t.references :organization, null: false, index: true, type: :uuid, foreign_key: { to_table: :zaikio_organizations }
      t.references :person, null: false, index: true, type: :uuid, foreign_key: { to_table: :zaikio_people }
      t.string :roles, array: true, null: false, default: []
      t.timestamps
    end
  end
end
