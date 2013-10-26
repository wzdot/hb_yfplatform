class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :device_area, :null => false
      t.references :model_style, :null => false
      t.string :phasic, :length => 3
      t.string :local_scene_name
      t.references :vender
      t.integer :cur_status

      t.timestamps
    end

    add_index :devices, :device_area_id
    add_index :devices, :model_style_id
    add_index :devices, [ :device_area_id, :model_style_id, :phasic ], :name => "unique_index", :unique => true
  end
end
