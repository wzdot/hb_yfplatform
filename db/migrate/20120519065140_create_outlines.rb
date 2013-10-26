class CreateOutlines < ActiveRecord::Migration
  def change
    create_table :outlines do |t|
      t.references :model_style, :null => false
      t.references :part_position, :null => false
      t.text :outline_text
      t.text :ana_unit_text
      t.string :outline_vector_file_name
      t.string :outline_vector_content_type
      t.integer :outline_vector_file_size
      t.datetime :outline_vector_updated_at
      t.string :standard_ir_file_name
      t.string :standard_ir_content_type
      t.integer :standard_ir_file_size
      t.datetime :standard_ir_updated_at
      t.string :standard_vi_file_name
      t.string :standard_vi_content_type
      t.integer :standard_vi_file_size
      t.datetime :standard_vi_updated_at
      t.boolean :outline_vector_unsatisfy, :default => false
      t.boolean :standard_ir_unsatisfy, :default => false
      t.boolean :standard_vi_unsatisfy, :default => false
      t.boolean :rule_unsatisfy, :default => false

      t.string :outline_vector_md5, :limit => 32
      t.string :standard_ir_md5, :limit => 32
      t.string :standard_vi_md5, :limit => 32

      t.timestamps
    end

    add_index :outlines, :model_style_id
    add_index :outlines, :part_position_id
    add_index :outlines, :standard_ir_updated_at, :name => 'index_standard_ir_updated_at'
    add_index :outlines, [ :model_style_id, :part_position_id ], :name => "unique_index", :unique => true
  end
end
