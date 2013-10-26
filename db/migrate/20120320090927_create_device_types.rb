class CreateDeviceTypes < ActiveRecord::Migration
  def change
    create_table :device_types do |t|
      t.string :name, :null => false
      t.string :notes
      t.references :parent

      t.timestamps
    end

    add_index :device_types, :name
    add_index :device_types, :parent_id
    add_index :device_types, [ :parent_id, :name ], :name => "unique_index", :unique => true
  end
end
