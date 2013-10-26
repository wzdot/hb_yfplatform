class CreateReportTemplates < ActiveRecord::Migration
  def change
    create_table :report_templates do |t|
      t.string :name, :null => false
      t.string :order_by1
      t.string :order_by2
      t.string :order_by3
      t.string :order_by4
      t.string :order_by5
      t.string :order_by6
      t.string :cover_file_name
      t.string :cover_content_type
      t.integer :cover_file_size
      t.datetime :cover_updated_at
      t.string :preface_file_name
      t.string :preface_content_type
      t.integer :preface_file_size
      t.datetime :preface_updated_at
      t.string :contents_file_name
      t.string :contents_content_type
      t.integer :contents_file_size
      t.datetime :contents_updated_at
      t.string :page_header_file_name
      t.string :page_header_content_type
      t.integer :page_header_file_size
      t.datetime :page_header_updated_at
      t.string :page_footer_file_name
      t.string :page_footer_content_type
      t.integer :page_footer_file_size
      t.datetime :page_footer_updated_at
      t.string :detail_file_name
      t.string :detail_content_type
      t.integer :detail_file_size
      t.datetime :detail_updated_at
      t.string :back_cover_file_name
      t.string :back_cover_content_type
      t.integer :back_cover_file_size
      t.datetime :back_cover_updated_at
      t.string :cover_md5, :limit => 32
      t.string :preface_md5, :limit => 32
      t.string :contents_md5, :limit => 32
      t.string :page_header_md5, :limit => 32
      t.string :page_footer_md5, :limit => 32
      t.string :detail_md5, :limit => 32
      t.string :back_cover_md5, :limit => 32

      t.timestamps
    end

    add_index :report_templates, :name, :unique => true
  end
end
