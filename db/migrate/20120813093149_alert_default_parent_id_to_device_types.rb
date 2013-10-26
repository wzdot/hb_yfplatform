class AlertDefaultParentIdToDeviceTypes < ActiveRecord::Migration
  def up
  	change_column :device_types, :parent_id, :integer, :default => 0, :null => false
  	execute <<-SQL
      UPDATE device_types SET parent_id=0 WHERE parent_id IS NULL
    SQL
  end

  def down
  end
end
