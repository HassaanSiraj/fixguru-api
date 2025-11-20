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

ActiveRecord::Schema[7.1].define(version: 2025_11_20_155832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "user_id", null: false
    t.decimal "proposed_cost", precision: 10, scale: 2, null: false
    t.text "proposal_message", null: false
    t.string "estimated_time"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id", "user_id"], name: "index_bids_on_job_id_and_user_id", unique: true
    t.index ["job_id"], name: "index_bids_on_job_id"
    t.index ["status"], name: "index_bids_on_status"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "budget", precision: 10, scale: 2
    t.string "location", null: false
    t.string "status", default: "open"
    t.bigint "assigned_provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_provider_id"], name: "index_jobs_on_assigned_provider_id"
    t.index ["category_id"], name: "index_jobs_on_category_id"
    t.index ["created_at"], name: "index_jobs_on_created_at"
    t.index ["status"], name: "index_jobs_on_status"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.text "content", null: false
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id", "receiver_id"], name: "index_messages_on_sender_id_and_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "payment_method", null: false
    t.string "status", default: "pending"
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_payments_on_status"
    t.index ["subscription_id"], name: "index_payments_on_subscription_id"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name"
    t.string "cnic_number"
    t.text "skills"
    t.text "experience"
    t.text "service_areas"
    t.string "verification_status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_provider_profiles_on_user_id"
    t.index ["verification_status"], name: "index_provider_profiles_on_verification_status"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan_type", default: "free", null: false
    t.string "status", default: "active"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_type"], name: "index_subscriptions_on_plan_type"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "service_seeker", null: false
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bids", "jobs"
  add_foreign_key "bids", "users"
  add_foreign_key "jobs", "categories"
  add_foreign_key "jobs", "users"
  add_foreign_key "jobs", "users", column: "assigned_provider_id"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "payments", "subscriptions"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "subscriptions", "users"
end
