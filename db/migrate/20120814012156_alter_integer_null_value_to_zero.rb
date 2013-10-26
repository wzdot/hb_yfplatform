class AlterIntegerNullValueToZero < ActiveRecord::Migration
  def up
  	change_column :device_types, :parent_id, :integer, :default => 0, :null => false
  	change_column :regions, :parent_id, :integer, :default => 0, :null => false
  	change_column :device_types, :parent_id, :integer, :default => 0, :null => false
  	change_column :model_styles, :voltage_level_id, :integer, :default => 0, :null => false
  	change_column :device_areas, :substation_id, :integer, :default => 0, :null => false
		change_column :device_areas, :voltage_level_id, :integer, :default => 0, :null => false
		change_column :devices, :device_area_id, :integer, :default => 0, :null => false
		change_column :devices, :model_style_id, :integer, :default => 0, :null => false
		change_column :devices, :phasic, :string, :null => false
		change_column :detection_resources, :detection_id, :integer, :null => false
		
  	
  	execute <<-SQL
      UPDATE device_types SET parent_id=0 WHERE parent_id IS NULL;
    SQL
    execute <<-SQL
      UPDATE regions SET parent_id=0 WHERE parent_id IS NULL
    SQL
    execute <<-SQL
      UPDATE device_types SET parent_id=0 WHERE parent_id IS NULL
    SQL

		execute <<-SQL
      UPDATE model_styles SET voltage_level_id=0 WHERE voltage_level_id IS NULL
    SQL

    execute <<-SQL
      UPDATE device_areas SET substation_id=0 WHERE substation_id IS NULL
    SQL

    execute <<-SQL
      UPDATE device_areas SET voltage_level_id=0 WHERE voltage_level_id IS NULL
    SQL

    execute <<-SQL
      UPDATE devices SET device_area_id=0 WHERE device_area_id IS NULL
    SQL

    execute <<-SQL
      UPDATE devices SET model_style_id=0 WHERE model_style_id IS NULL
    SQL
  end

  def down
  end
end
