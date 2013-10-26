class CreateDeviceAreaTypes < ActiveRecord::Migration
  def change
    create_table :device_area_types do |t|
      t.string :name, :null => false
      t.string :notes

      t.timestamps
    end

    add_index :device_area_types, :name, :unique => true
  end
end
