# This migration comes from zaiku (originally 20191017125254)
class CreateZaikuOrganizationMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :zaiku_organization_memberships, id: :uuid do |t|
      t.references :organization, null: false, index: true, type: :uuid, foreign_key: { to_table: :zaiku_organizations }
      t.references :person, null: false, index: true, type: :uuid, foreign_key: { to_table: :zaiku_people }
      t.string :roles, array: true, null: false, default: []
      t.timestamps
    end
  end
end
