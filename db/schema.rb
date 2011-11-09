# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111109195759) do

  create_table "answers", :id => false, :force => true do |t|
    t.integer  "id",             :limit => 8
    t.integer  "user_id",        :limit => 8,                    :null => false
    t.integer  "question_id",    :limit => 8,                    :null => false
    t.text     "content",                                        :null => false
    t.boolean  "is_correct",                  :default => false
    t.integer  "votes_count",                 :default => 0
    t.integer  "comments_count",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"
  add_index "answers", ["user_id"], :name => "index_answers_on_user_id"

  create_table "comments", :id => false, :force => true do |t|
    t.integer  "id",         :limit => 8
    t.integer  "user_id",    :limit => 8, :null => false
    t.integer  "pixar_id",   :limit => 8, :null => false
    t.string   "name",                    :null => false
    t.text     "content",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["pixar_id"], :name => "index_comments_on_pixar_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "credit_transactions", :force => true do |t|
    t.integer  "user_id",      :limit => 8,                                                 :null => false
    t.integer  "winner_id",    :limit => 8,                               :default => 0
    t.integer  "magic_id",     :limit => 8,                                                 :null => false
    t.decimal  "value",                     :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "payment",                                                 :default => true
    t.integer  "trade_type",                                              :default => 0
    t.integer  "trade_status",                                            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_transactions", ["magic_id"], :name => "index_credit_transactions_on_magic_id"
  add_index "credit_transactions", ["user_id"], :name => "index_credit_transactions_on_user_id"
  add_index "credit_transactions", ["winner_id"], :name => "index_credit_transactions_on_winner_id"

  create_table "photos", :force => true do |t|
    t.integer  "user_id",    :limit => 8, :null => false
    t.string   "image"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["user_id"], :name => "index_photos_on_user_id"

  create_table "questions", :id => false, :force => true do |t|
    t.integer  "id",                :limit => 8
    t.integer  "user_id",           :limit => 8,                                                  :null => false
    t.string   "title",                                                                           :null => false
    t.text     "content",                                                                         :null => false
    t.string   "rules_list",                                                   :default => ""
    t.string   "customized_rule",                                              :default => ""
    t.decimal  "credit",                         :precision => 8, :scale => 2, :default => 0.0
    t.integer  "reputation",                                                   :default => 0
    t.boolean  "is_free",                                                      :default => false
    t.integer  "end_date",                                                     :default => 0
    t.integer  "votes_count",                                                  :default => 0
    t.integer  "answers_count",                                                :default => 0
    t.integer  "comments_count",                                               :default => 0
    t.integer  "correct_answer_id", :limit => 8,                               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["user_id"], :name => "index_questions_on_user_id"

  create_table "recharge_records", :id => false, :force => true do |t|
    t.integer  "id",           :limit => 8
    t.integer  "user_id",      :limit => 8,                                                :null => false
    t.decimal  "credit",                    :precision => 8, :scale => 2, :default => 0.0
    t.integer  "trade_type",                                              :default => 0
    t.integer  "trade_status",                                            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recharge_records", ["user_id"], :name => "index_recharge_records_on_user_id"

  create_table "reputation_transactions", :force => true do |t|
    t.integer  "user_id",      :limit => 8,                   :null => false
    t.integer  "winner_id",    :limit => 8, :default => 0
    t.integer  "magic_id",     :limit => 8,                   :null => false
    t.integer  "value",                     :default => 0,    :null => false
    t.boolean  "payment",                   :default => true
    t.integer  "trade_type",                :default => 0
    t.integer  "trade_status",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reputation_transactions", ["magic_id"], :name => "index_reputation_transactions_on_magic_id"
  add_index "reputation_transactions", ["user_id"], :name => "index_reputation_transactions_on_user_id"
  add_index "reputation_transactions", ["winner_id"], :name => "index_reputation_transactions_on_winner_id"

  create_table "users", :primary_key => "email", :force => true do |t|
    t.integer  "id",                     :limit => 8
    t.string   "name",                                                                :default => ""
    t.string   "avatar",                                                              :default => ""
    t.string   "about_me",                                                            :default => ""
    t.string   "encrypted_password",     :limit => 128,                               :default => "",  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.decimal  "credit",                                :precision => 8, :scale => 2, :default => 0.0
    t.integer  "reputation",                                                          :default => 0
    t.integer  "questions_count",                                                     :default => 0
    t.integer  "answers_count",                                                       :default => 0
    t.integer  "comments_count",                                                      :default => 0
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.boolean  "vote",                       :default => false
    t.integer  "voteable_id",   :limit => 8,                    :null => false
    t.integer  "voter_id",      :limit => 8,                    :null => false
    t.string   "voter_type",                                    :null => false
    t.string   "voteable_type",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "index_votes_on_voteable_id_and_voteable_type"
  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "fk_one_vote_per_user_per_entity", :unique => true
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
