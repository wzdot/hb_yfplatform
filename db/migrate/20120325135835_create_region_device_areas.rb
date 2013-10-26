# -*- coding: utf-8 -*-
#已不需要?
class CreateRegionDeviceAreas < ActiveRecord::Migration
  def change
    create_table :region_device_areas do |t|
      t.references :region, :null => false
      t.references :device_area, :null => false
      t.references :voltage_level

      t.timestamps
    end

    add_index :region_device_areas, :region_id
    add_index :region_device_areas, :device_area_id
    add_index :region_device_areas, [ :region_id, :device_area_id ], :name => "unique_index", :unique => true
  end
end
