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

ActiveRecord::Schema[8.1].define(version: 20_240_909_094_424) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "photos", force: :cascade do |t|
    t.datetime("created_at", null: false)
    t.string("image")
    t.integer("sake_id")
    t.datetime("updated_at", null: false)
  end

  create_table "sakes", force: :cascade do |t|
    t.float("alcohol")
    t.float("aminosando")
    t.text("aroma_impression")
    t.integer("aroma_value")
    t.string("awa")
    t.date("bindume_on")
    t.integer("bottle_level", default: 0)
    t.date("brewery_year")
    t.string("color")
    t.datetime("created_at", null: false)
    t.datetime("emptied_at", null: false)
    t.string("genryomai")
    t.integer("hiire", default: 0)
    t.string("kakemai")
    t.string("kobo")
    t.string("kura")
    t.integer("moto", default: 0)
    t.string("name")
    t.string("nigori")
    t.float("nihonshudo")
    t.text("note")
    t.datetime("opened_at", null: false)
    t.integer("price")
    t.integer("rating", default: 0, null: false)
    t.string("roka")
    t.float("sando")
    t.string("season")
    t.integer("seimai_buai")
    t.string("shibori")
    t.integer("size", default: 720)
    t.text("taste_impression")
    t.integer("taste_value")
    t.string("todofuken")
    t.integer("tokutei_meisho", default: 0)
    t.datetime("updated_at", null: false)
    t.integer("warimizu", default: 0)
  end

  create_table "users", force: :cascade do |t|
    t.boolean("admin", default: false)
    t.datetime("confirmation_sent_at", precision: nil)
    t.string("confirmation_token")
    t.datetime("confirmed_at", precision: nil)
    t.datetime("created_at", null: false)
    t.datetime("current_sign_in_at", precision: nil)
    t.string("current_sign_in_ip")
    t.string("email", default: "", null: false)
    t.string("encrypted_password", default: "", null: false)
    t.integer("failed_attempts", default: 0, null: false)
    t.datetime("invitation_accepted_at", precision: nil)
    t.datetime("invitation_created_at", precision: nil)
    t.integer("invitation_limit")
    t.datetime("invitation_sent_at", precision: nil)
    t.string("invitation_token")
    t.integer("invited_by_id")
    t.string("invited_by_type")
    t.datetime("last_sign_in_at", precision: nil)
    t.string("last_sign_in_ip")
    t.datetime("locked_at", precision: nil)
    t.datetime("remember_created_at", precision: nil)
    t.datetime("reset_password_sent_at", precision: nil)
    t.string("reset_password_token")
    t.integer("sign_in_count", default: 0, null: false)
    t.string("unconfirmed_email")
    t.string("unlock_token")
    t.datetime("updated_at", null: false)
    t.index(["email"], name: "index_users_on_email", unique: true)
    t.index(["invitation_token"], name: "index_users_on_invitation_token", unique: true)
    t.index(["reset_password_token"], name: "index_users_on_reset_password_token", unique: true)
    t.index(["unlock_token"], name: "index_users_on_unlock_token", unique: true)
  end
end
