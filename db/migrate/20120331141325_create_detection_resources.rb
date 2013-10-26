class CreateDetectionResources < ActiveRecord::Migration
  def change
    create_table :detection_resources do |t|
      t.references :detection
      t.integer     :irv_pos_start
      t.integer     :irv_pos_end
      t.string      :key_frames
      t.text        :params_json
      t.string      :irp_file_name
      t.string      :irp_content_type
      t.integer     :irp_file_size
      t.datetime    :irp_updated_at
      t.string      :irjson_file_name
      t.string      :irjson_content_type
      t.integer     :irjson_file_size
      t.datetime    :irjson_updated_at
      t.string      :irimage_file_name
      t.string      :irimage_content_type
      t.integer     :irimage_file_size
      t.datetime    :irimage_updated_at
      t.string      :viimage_file_name
      t.string      :viimage_content_type
      t.integer     :viimage_file_size
      t.datetime    :viimage_updated_at
      t.string      :irv_file_name
      t.string      :irv_content_type
      t.integer     :irv_file_size
      t.datetime    :irv_updated_at

      t.string :irp_md5, :limit => 32
      t.string :irjson_md5, :limit => 32
      t.string :irimage_md5, :limit => 32
      t.string :viimage_md5, :limit => 32
      t.string :irv_md5, :limit => 32

      t.timestamps
    end

    add_index :detection_resources, :detection_id, :unique => true
  end
end
