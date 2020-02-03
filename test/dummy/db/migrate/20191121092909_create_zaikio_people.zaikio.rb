# This migration comes from zaikio (originally 20191017125247)
class CreateZaikioPeople < ActiveRecord::Migration[6.0]
  def change
    create_table :zaikio_people, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :locale, null: false
      t.string :time_zone, null: false
      t.timestamps
    end
  end
end
