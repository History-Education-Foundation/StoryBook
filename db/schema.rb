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

ActiveRecord::Schema[7.2].define(version: 2025_08_26_194439) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checkpoint_blobs", primary_key: ["thread_id", "checkpoint_ns", "channel", "version"], force: :cascade do |t|
    t.text "thread_id", null: false
    t.text "checkpoint_ns", default: "", null: false
    t.text "channel", null: false
    t.text "version", null: false
    t.text "type", null: false
    t.binary "blob"
    t.index ["thread_id"], name: "checkpoint_blobs_thread_id_idx"
  end

  create_table "checkpoint_migrations", primary_key: "v", id: :integer, default: nil, force: :cascade do |t|
  end

  create_table "checkpoint_writes", primary_key: ["thread_id", "checkpoint_ns", "checkpoint_id", "task_id", "idx"], force: :cascade do |t|
    t.text "thread_id", null: false
    t.text "checkpoint_ns", default: "", null: false
    t.text "checkpoint_id", null: false
    t.text "task_id", null: false
    t.integer "idx", null: false
    t.text "channel", null: false
    t.text "type"
    t.binary "blob", null: false
    t.text "task_path", default: "", null: false
    t.index ["thread_id"], name: "checkpoint_writes_thread_id_idx"
  end

  create_table "checkpoints", primary_key: ["thread_id", "checkpoint_ns", "checkpoint_id"], force: :cascade do |t|
    t.text "thread_id", null: false
    t.text "checkpoint_ns", default: "", null: false
    t.text "checkpoint_id", null: false
    t.text "parent_checkpoint_id"
    t.text "type"
    t.jsonb "checkpoint", null: false
    t.jsonb "metadata", default: {}, null: false
    t.index ["thread_id"], name: "checkpoints_thread_id_idx"
  end

  create_table "goals", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "status"
    t.date "target_date"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "goal_id"
    t.index ["goal_id"], name: "index_journal_entries_on_goal_id"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "goals", "users"
  add_foreign_key "journal_entries", "users"
end
