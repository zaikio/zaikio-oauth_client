class CreateZaikuPeople < ActiveRecord::Migration[6.0]
  def change
    create_table :zaiku_people, type: :uuid do |t|
      t.string :first_name, null: false
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :locale, null: false
      t.string :time_zone, null: false
      t.timestamps
    end
  end
end
