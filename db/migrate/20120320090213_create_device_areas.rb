class CreateDeviceAreas < ActiveRecord::Migration
  def change
    create_table :device_areas do |t|
      t.references  :substation, :null => false
      t.references  :voltage_level
      t.string      :device_area_name, :null => false
      t.float       :longitude  # 经度
      t.float       :latitude   # 纬度
      t.float       :altitude   # 海拔

      t.timestamps
    end

    add_index :device_areas, :substation_id
    add_index :device_areas, :device_area_name
    add_index :device_areas, :voltage_level_id
    add_index :device_areas, [ :substation_id, :voltage_level_id, :device_area_name ], :name => "unique_index", :unique => true
  end
end
