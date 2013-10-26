class CreateSubstations < ActiveRecord::Migration
  def change
    create_table :substations do |t|
      t.references :region, :null => false
      t.string :name, :null => false
      t.references :voltage_level, :null => false
      t.string :notes
      t.integer :run_zone_id, :default => 0

      t.timestamps
    end

    add_index :substations, :region_id
    add_index :substations, :voltage_level_id
    add_index :substations, :name
    add_index :substations, [ :region_id, :name, :voltage_level_id ], :name => "unique_index", :unique => true
  end
end
