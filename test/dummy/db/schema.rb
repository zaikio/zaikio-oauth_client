# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_04_25_130923) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "zaikio_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "bearer_type", default: "Organization", null: false
    t.string "bearer_id", null: false
    t.string "audience", null: false
    t.datetime "expires_at", precision: nil
    t.string "scopes", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "requested_scopes", default: [], null: false, array: true
    t.string "token", null: false
    t.string "refresh_token"
    t.index ["audience", "bearer_type", "bearer_id"], name: "zaikio_access_tokens_lookup_index"
    t.index ["expires_at"], name: "index_zaikio_access_tokens_on_expires_at"
  end

end
