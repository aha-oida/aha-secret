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

ActiveRecord::Schema[7.2].define(version: 2024_09_14_195836) do
  create_table "bins", id: false, force: :cascade do |t|
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id"
    t.datetime "expire_date", default: -> { "datetime('now','+7 day','localtime')" }
    t.boolean "has_password", default: false
    t.index ["id"], name: "index_bins_on_id", unique: true
  end
end
