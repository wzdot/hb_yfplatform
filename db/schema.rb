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

ActiveRecord::Schema.define(:version => 20130417072926) do

  create_table "detect_rules", :force => true do |t|
    t.integer  "outline_id",      :null => false
    t.integer  "fault_nature_id", :null => false
    t.integer  "order_num",       :null => false
    t.string   "rule_title",      :null => false
    t.text     "rule_text"
    t.text     "rule_formula"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "detect_rules", ["fault_nature_id"], :name => "index_detect_rules_on_fault_nature_id"
  add_index "detect_rules", ["outline_id", "fault_nature_id", "order_num"], :name => "unique_index", :unique => true
  add_index "detect_rules", ["outline_id"], :name => "index_detect_rules_on_outline_id"

  create_table "detection_resources", :force => true do |t|
    t.integer  "detection_id",                       :null => false
    t.integer  "irv_pos_start"
    t.integer  "irv_pos_end"
    t.string   "key_frames"
    t.text     "params_json"
    t.string   "irp_file_name"
    t.string   "irp_content_type"
    t.integer  "irp_file_size"
    t.datetime "irp_updated_at"
    t.string   "irjson_file_name"
    t.string   "irjson_content_type"
    t.integer  "irjson_file_size"
    t.datetime "irjson_updated_at"
    t.string   "irimage_file_name"
    t.string   "irimage_content_type"
    t.integer  "irimage_file_size"
    t.datetime "irimage_updated_at"
    t.string   "viimage_file_name"
    t.string   "viimage_content_type"
    t.integer  "viimage_file_size"
    t.datetime "viimage_updated_at"
    t.string   "irv_file_name"
    t.string   "irv_content_type"
    t.integer  "irv_file_size"
    t.datetime "irv_updated_at"
    t.string   "irp_md5",              :limit => 32
    t.string   "irjson_md5",           :limit => 32
    t.string   "irimage_md5",          :limit => 32
    t.string   "viimage_md5",          :limit => 32
    t.string   "irv_md5",              :limit => 32
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "detection_resources", ["detection_id"], :name => "index_detection_resources_on_detection_id", :unique => true

  create_table "detections", :force => true do |t|
    t.date     "detect_date",            :null => false
    t.time     "detect_time",            :null => false
    t.integer  "device_id",              :null => false
    t.integer  "part_position_id",       :null => false
    t.integer  "fault_nature_id"
    t.datetime "fixed_date"
    t.integer  "fix_method_id"
    t.integer  "execute_case_id"
    t.integer  "fault_degree_id"
    t.integer  "detect_rule_id"
    t.float    "running_voltage"
    t.float    "electrical_current"
    t.integer  "substation_id",          :null => false
    t.integer  "device_area_id",         :null => false
    t.integer  "device_area_voltage_id", :null => false
    t.integer  "device_type_id",         :null => false
    t.integer  "model_style_id",         :null => false
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "detections", ["detect_date", "detect_time"], :name => "date_time"
  add_index "detections", ["device_id", "part_position_id", "detect_date", "detect_time"], :name => "unique_index", :unique => true
  add_index "detections", ["device_type_id"], :name => "index_detections_on_device_type_id"
  add_index "detections", ["fault_nature_id", "substation_id"], :name => "fault_count_index"
  add_index "detections", ["id"], :name => "index_detections_on_id"
  add_index "detections", ["substation_id"], :name => "index_detections_on_substation_id"

  create_table "device_area_shoot_sequences", :force => true do |t|
    t.integer  "shoot_sequence_id", :null => false
    t.integer  "order_num",         :null => false
    t.integer  "device_area_id",    :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "device_area_shoot_sequences", ["device_area_id"], :name => "index_device_area_shoot_sequences_on_device_area_id"
  add_index "device_area_shoot_sequences", ["shoot_sequence_id", "device_area_id"], :name => "unique_index", :unique => true
  add_index "device_area_shoot_sequences", ["shoot_sequence_id"], :name => "index_device_area_shoot_sequences_on_shoot_sequence_id"

  create_table "device_area_types", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "device_area_types", ["name"], :name => "index_device_area_types_on_name", :unique => true

  create_table "device_areas", :force => true do |t|
    t.integer  "substation_id",    :default => 0, :null => false
    t.integer  "voltage_level_id", :default => 0, :null => false
    t.string   "device_area_name",                :null => false
    t.float    "longitude"
    t.float    "latitude"
    t.float    "altitude"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "device_areas", ["device_area_name"], :name => "index_device_areas_on_device_area_name"
  add_index "device_areas", ["substation_id", "voltage_level_id", "device_area_name"], :name => "unique_index", :unique => true
  add_index "device_areas", ["substation_id"], :name => "index_device_areas_on_substation_id"
  add_index "device_areas", ["voltage_level_id"], :name => "index_device_areas_on_voltage_level_id"

  create_table "device_shoot_sequences", :force => true do |t|
    t.integer  "shoot_sequence_id", :null => false
    t.integer  "device_area_id",    :null => false
    t.integer  "order_num",         :null => false
    t.integer  "device_id",         :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "device_shoot_sequences", ["device_area_id"], :name => "index_device_shoot_sequences_on_device_area_id"
  add_index "device_shoot_sequences", ["device_id"], :name => "index_device_shoot_sequences_on_device_id"
  add_index "device_shoot_sequences", ["shoot_sequence_id", "device_area_id", "order_num"], :name => "unique_index", :unique => true
  add_index "device_shoot_sequences", ["shoot_sequence_id"], :name => "index_device_shoot_sequences_on_shoot_sequence_id"

  create_table "device_types", :force => true do |t|
    t.string   "name",                      :null => false
    t.string   "notes"
    t.integer  "parent_id",  :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "device_types", ["name"], :name => "index_device_types_on_name"
  add_index "device_types", ["parent_id", "name"], :name => "unique_index", :unique => true
  add_index "device_types", ["parent_id"], :name => "index_device_types_on_parent_id"

  create_table "devices", :force => true do |t|
    t.integer  "device_area_id",   :default => 0, :null => false
    t.integer  "model_style_id",   :default => 0, :null => false
    t.string   "phasic",                          :null => false
    t.string   "local_scene_name"
    t.integer  "vender_id"
    t.integer  "cur_status"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "devices", ["device_area_id", "model_style_id", "phasic"], :name => "unique_index", :unique => true
  add_index "devices", ["device_area_id"], :name => "index_devices_on_device_area_id"
  add_index "devices", ["model_style_id"], :name => "index_devices_on_model_style_id"

  create_table "employees", :force => true do |t|
    t.string   "email",      :null => false
    t.string   "name",       :null => false
    t.string   "mobile"
    t.string   "tel"
    t.integer  "region_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "employees", ["email"], :name => "index_employees_on_email", :unique => true
  add_index "employees", ["name"], :name => "index_employees_on_name"
  add_index "employees", ["region_id"], :name => "index_employees_on_region_id"

  create_table "execute_cases", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "execute_cases", ["name"], :name => "index_execute_cases_on_name", :unique => true

  create_table "fault_degrees", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "fault_degrees", ["name"], :name => "index_fault_degrees_on_name", :unique => true

  create_table "fault_natures", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "fault_natures", ["name"], :name => "index_fault_natures_on_name", :unique => true

  create_table "fix_methods", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "fix_methods", ["name"], :name => "index_fix_methods_on_name", :unique => true

  create_table "model_styles", :force => true do |t|
    t.string   "model_style",                     :null => false
    t.string   "name",                            :null => false
    t.string   "notes"
    t.integer  "device_type_id",                  :null => false
    t.integer  "voltage_level_id", :default => 0, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "model_styles", ["device_type_id", "voltage_level_id", "model_style"], :name => "unique_index", :unique => true
  add_index "model_styles", ["device_type_id"], :name => "index_model_styles_on_device_type_id"
  add_index "model_styles", ["model_style"], :name => "index_model_styles_on_model_style"
  add_index "model_styles", ["name"], :name => "index_model_styles_on_name"
  add_index "model_styles", ["voltage_level_id"], :name => "index_model_styles_on_voltage_level_id"

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.string   "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "uid",          :null => false
    t.string   "secret",       :null => false
    t.string   "redirect_uri", :null => false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], :name => "index_oauth_applications_on_owner_id_and_owner_type"
  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "outlines", :force => true do |t|
    t.integer  "model_style_id",                                               :null => false
    t.integer  "part_position_id",                                             :null => false
    t.text     "outline_text"
    t.text     "ana_unit_text"
    t.string   "outline_vector_file_name"
    t.string   "outline_vector_content_type"
    t.integer  "outline_vector_file_size"
    t.datetime "outline_vector_updated_at"
    t.string   "standard_ir_file_name"
    t.string   "standard_ir_content_type"
    t.integer  "standard_ir_file_size"
    t.datetime "standard_ir_updated_at"
    t.string   "standard_vi_file_name"
    t.string   "standard_vi_content_type"
    t.integer  "standard_vi_file_size"
    t.datetime "standard_vi_updated_at"
    t.boolean  "outline_vector_unsatisfy",                  :default => false
    t.boolean  "standard_ir_unsatisfy",                     :default => false
    t.boolean  "standard_vi_unsatisfy",                     :default => false
    t.boolean  "rule_unsatisfy",                            :default => false
    t.string   "outline_vector_md5",          :limit => 32
    t.string   "standard_ir_md5",             :limit => 32
    t.string   "standard_vi_md5",             :limit => 32
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "outlines", ["model_style_id", "part_position_id"], :name => "unique_index", :unique => true
  add_index "outlines", ["model_style_id"], :name => "index_outlines_on_model_style_id"
  add_index "outlines", ["part_position_id"], :name => "index_outlines_on_part_position_id"
  add_index "outlines", ["standard_ir_updated_at"], :name => "index_standard_ir_updated_at"

  create_table "part_position_shoot_sequences", :force => true do |t|
    t.integer  "shoot_sequence_id", :null => false
    t.integer  "device_area_id",    :null => false
    t.integer  "device_id",         :null => false
    t.integer  "order_num",         :null => false
    t.integer  "part_position_id",  :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "part_position_shoot_sequences", ["device_area_id"], :name => "index_part_position_shoot_sequences_on_device_area_id"
  add_index "part_position_shoot_sequences", ["device_id"], :name => "index_part_position_shoot_sequences_on_device_id"
  add_index "part_position_shoot_sequences", ["part_position_id"], :name => "index_part_position_shoot_sequences_on_part_position_id"
  add_index "part_position_shoot_sequences", ["shoot_sequence_id", "device_area_id", "device_id", "order_num"], :name => "unique_index", :unique => true
  add_index "part_position_shoot_sequences", ["shoot_sequence_id"], :name => "index_part_position_shoot_sequences_on_shoot_sequence_id"

  create_table "part_positions", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "part_positions", ["name"], :name => "index_part_positions_on_name", :unique => true

  create_table "region_device_areas", :force => true do |t|
    t.integer  "region_id",        :null => false
    t.integer  "device_area_id",   :null => false
    t.integer  "voltage_level_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "region_device_areas", ["device_area_id"], :name => "index_region_device_areas_on_device_area_id"
  add_index "region_device_areas", ["region_id", "device_area_id"], :name => "unique_index", :unique => true
  add_index "region_device_areas", ["region_id"], :name => "index_region_device_areas_on_region_id"

  create_table "regions", :force => true do |t|
    t.string   "name",                      :null => false
    t.string   "notes"
    t.integer  "parent_id",  :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "regions", ["name"], :name => "index_regions_on_name"
  add_index "regions", ["parent_id", "name"], :name => "unique_index", :unique => true
  add_index "regions", ["parent_id"], :name => "index_regions_on_parent_id"

  create_table "report_templates", :force => true do |t|
    t.string   "name",                                                  :null => false
    t.string   "order_by1"
    t.string   "order_by2"
    t.string   "order_by3"
    t.string   "order_by4"
    t.string   "order_by5"
    t.string   "order_by6"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.string   "preface_file_name"
    t.string   "preface_content_type"
    t.integer  "preface_file_size"
    t.datetime "preface_updated_at"
    t.string   "contents_file_name"
    t.string   "contents_content_type"
    t.integer  "contents_file_size"
    t.datetime "contents_updated_at"
    t.string   "page_header_file_name"
    t.string   "page_header_content_type"
    t.integer  "page_header_file_size"
    t.datetime "page_header_updated_at"
    t.string   "page_footer_file_name"
    t.string   "page_footer_content_type"
    t.integer  "page_footer_file_size"
    t.datetime "page_footer_updated_at"
    t.string   "detail_file_name"
    t.string   "detail_content_type"
    t.integer  "detail_file_size"
    t.datetime "detail_updated_at"
    t.string   "back_cover_file_name"
    t.string   "back_cover_content_type"
    t.integer  "back_cover_file_size"
    t.datetime "back_cover_updated_at"
    t.string   "cover_md5",                :limit => 32
    t.string   "preface_md5",              :limit => 32
    t.string   "contents_md5",             :limit => 32
    t.string   "page_header_md5",          :limit => 32
    t.string   "page_footer_md5",          :limit => 32
    t.string   "detail_md5",               :limit => 32
    t.string   "back_cover_md5",           :limit => 32
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "template_type",                          :default => 0
  end

  add_index "report_templates", ["name"], :name => "index_report_templates_on_name", :unique => true

  create_table "shoot_sequences", :force => true do |t|
    t.integer  "substation_id", :null => false
    t.string   "name",          :null => false
    t.text     "notes"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "shoot_sequences", ["name"], :name => "index_shoot_sequences_on_name"
  add_index "shoot_sequences", ["substation_id", "name"], :name => "unique_index", :unique => true
  add_index "shoot_sequences", ["substation_id"], :name => "index_shoot_sequences_on_substation_id"

  create_table "substations", :force => true do |t|
    t.integer  "region_id",                       :null => false
    t.string   "name",                            :null => false
    t.integer  "voltage_level_id",                :null => false
    t.string   "notes"
    t.integer  "run_zone_id",      :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "substations", ["name"], :name => "index_substations_on_name"
  add_index "substations", ["region_id", "name", "voltage_level_id"], :name => "unique_index", :unique => true
  add_index "substations", ["region_id"], :name => "index_substations_on_region_id"
  add_index "substations", ["voltage_level_id"], :name => "index_substations_on_voltage_level_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",                   :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.boolean  "blocked",                              :default => false
    t.string   "name",                                 :default => "",    :null => false
    t.boolean  "admin",                                :default => false
    t.string   "mobile",                 :limit => 11,                    :null => false
    t.string   "sms_code",               :limit => 6
    t.datetime "sms_code_expired_at"
    t.string   "password_sms_code",      :limit => 6
    t.integer  "level",                                :default => 1,     :null => false
    t.integer  "item_id"
    t.integer  "parent_id"
    t.integer  "mask",                                 :default => 7,     :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "venders", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "tel"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "venders", ["name"], :name => "index_venders_on_name", :unique => true

  create_table "voltage_levels", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "voltage_levels", ["name"], :name => "index_voltage_levels_on_name", :unique => true

end
