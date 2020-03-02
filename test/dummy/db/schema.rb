# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_02_112443) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "zaikio_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "bearer_type"
    t.uuid "bearer_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.datetime "expires_at"
    t.string "scopes", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bearer_type", "bearer_id"], name: "index_zaikio_access_tokens_on_bearer_type_and_bearer_id"
    t.index ["expires_at"], name: "index_zaikio_access_tokens_on_expires_at"
    t.index ["refresh_token"], name: "index_zaikio_access_tokens_on_refresh_token", unique: true
    t.index ["token"], name: "index_zaikio_access_tokens_on_token", unique: true
  end

  create_table "zaikio_organization_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "person_id", null: false
    t.string "roles", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_zaikio_organization_memberships_on_organization_id"
    t.index ["person_id"], name: "index_zaikio_organization_memberships_on_person_id"
  end

  create_table "zaikio_organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "zaikio_people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "locale", null: false
    t.string "time_zone", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_zaikio_people_on_email", unique: true
  end

  create_table "zaikio_sites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_zaikio_sites_on_organization_id"
  end

  add_foreign_key "zaikio_organization_memberships", "zaikio_organizations", column: "organization_id"
  add_foreign_key "zaikio_organization_memberships", "zaikio_people", column: "person_id"
  add_foreign_key "zaikio_sites", "zaikio_organizations", column: "organization_id"
end
