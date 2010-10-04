# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 9) do

  create_table "big_brother_params", :force => true do |t|
    t.string  "param"
    t.text    "value"
    t.integer "big_brother_track_id", :limit => 11
  end

  add_index "big_brother_params", ["big_brother_track_id"], :name => "index_big_brother_params_on_big_brother_track_id"

  create_table "big_brother_tracks", :force => true do |t|
    t.string   "mturk_worker_id"
    t.string   "ip"
    t.string   "controller"
    t.string   "action"
    t.string   "method"
    t.boolean  "ajax"
    t.datetime "created_at"
  end

  add_index "big_brother_tracks", ["ip"], :name => "index_big_brother_tracks_on_ip"
  add_index "big_brother_tracks", ["mturk_worker_id"], :name => "index_big_brother_tracks_on_mturk_worker_id"

  create_table "browser_statuses", :force => true do |t|
    t.integer  "survey_id",  :limit => 11
    t.string   "status"
    t.datetime "created_at"
  end

  add_index "browser_statuses", ["survey_id"], :name => "index_browser_statuses_on_survey_id"

  create_table "rounded_corners", :force => true do |t|
    t.integer  "radius",     :limit => 11
    t.string   "border"
    t.string   "interior"
    t.datetime "created_at"
  end

  add_index "rounded_corners", ["radius"], :name => "index_rounded_corners_on_radius"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "survey_questions", :force => true do |t|
    t.integer  "survey_id",     :limit => 11
    t.string   "question_type"
    t.string   "signature"
    t.text     "responses"
    t.datetime "created_at"
  end

  add_index "survey_questions", ["survey_id"], :name => "index_survey_questions_on_survey_id"

  create_table "surveys", :force => true do |t|
    t.string   "mturk_hit_id"
    t.string   "mturk_group_id"
    t.integer  "version",             :limit => 3
    t.float    "wage"
    t.string   "country",             :limit => 2
    t.datetime "created_at"
    t.datetime "to_be_expired_at"
    t.text     "treatment"
    t.string   "ip_address"
    t.string   "mturk_assignment_id"
    t.string   "mturk_worker_id"
    t.datetime "started_at"
    t.datetime "read_directions_at"
    t.datetime "finished_at"
    t.text     "notes"
    t.datetime "rejected_at"
    t.datetime "paid_at"
    t.float    "bonus"
  end

  add_index "surveys", ["mturk_worker_id"], :name => "index_surveys_on_mturk_worker_id"

  create_table "version_infos", :force => true do |t|
    t.integer  "version",     :limit => 11
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "version_infos", ["version"], :name => "index_version_infos_on_version"

end
