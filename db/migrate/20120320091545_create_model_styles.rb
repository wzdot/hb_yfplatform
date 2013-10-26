class CreateModelStyles < ActiveRecord::Migration
  def change
    create_table :model_styles do |t|
      t.string :model_style, :null => false
      t.string :name, :null => false
      t.string :notes
      t.references :device_type, :null => false
      # t.references :vender
      t.references :voltage_level

      t.timestamps
    end

    add_index :model_styles, :model_style
    add_index :model_styles, :name
    # add_index :model_styles, :vender_id
    add_index :model_styles, :device_type_id
    add_index :model_styles, :voltage_level_id
    add_index :model_styles, [ :device_type_id, :voltage_level_id, :model_style ], :name => "unique_index", :unique => true
  end
end
