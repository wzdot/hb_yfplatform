class ModifyDetectionIndex < ActiveRecord::Migration
  def up
  	remove_index :detections, :detect_date if index_exists?(:detections, :detect_date)
    remove_index :detections, :detect_time if index_exists?(:detections, :detect_time)
    remove_index :detections, :device_id if index_exists?(:detections, :device_id)
    remove_index :detections, :execute_case_id if index_exists?(:detections, :execute_case_id)
    remove_index :detections, :fault_degree_id if index_exists?(:detections, :fault_degree_id)
    remove_index :detections, :fault_nature_id if index_exists?(:detections, :fault_nature_id)
    remove_index :detections, :fix_method_id if index_exists?(:detections, :fix_method_id)
    remove_index :detections, :part_position_id if index_exists?(:detections, :part_position_id)

    add_index :detections, :device_type_id unless index_exists?(:detections, :device_type_id)
    add_index :detections, :substation_id unless index_exists?(:detections, :substation_id)
    add_index :detections, [:fault_nature_id, :substation_id], :name => 'fault_count_index' unless index_exists?(:detections, [:fault_nature_id, :substation_id],:name => 'fault_count_index')
  end

  def down
  	add_index :detections, :detect_date
    add_index :detections, :detect_time
    add_index :detections, :device_id
    add_index :detections, :execute_case_id
    add_index :detections, :fault_degree_id
    add_index :detections, :fault_nature_id
    add_index :detections, :fix_method_id
    add_index :detections, :part_position_id

    remove_index :detections, :device_type_id
    remove_index :detections, :substation_id
    remove_index :detections, :name => 'fault_count_index'
  end
end
