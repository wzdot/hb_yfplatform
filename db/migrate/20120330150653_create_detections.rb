class CreateDetections < ActiveRecord::Migration
  def change
    create_table :detections do |t|
      t.date :detect_date, :null => false
      t.time :detect_time, :null => false
      t.references :device, :null => false
      t.references :part_position, :null => false
      t.references :fault_nature
      t.datetime   :fixed_date
      t.references :fix_method
      t.references :execute_case
      t.references :fault_degree
      t.references :detect_rule
      t.float :running_voltage
      t.float :electrical_current

      t.integer :substation_id, :null => false
      t.integer :device_area_id, :null => false
      t.integer :device_area_voltage_id, :null => false
      t.integer :device_type_id, :null => false
      t.integer :model_style_id, :null => false

      t.timestamps
    end

    add_index :detections, [ :device_id, :part_position_id, :detect_date, :detect_time ], :name => "unique_index", :unique => true
    add_index :detections, :fault_nature_id
    add_index :detections, :substation_id
    add_index :detections, :device_type_id
    add_index :detections, [:fault_nature_id, :substation_id], :name => 'fault_count_index'
    add_index :detections, [:detect_date, :detect_time], :name => 'date_time'
    add_index :detections, :id
  end
end
