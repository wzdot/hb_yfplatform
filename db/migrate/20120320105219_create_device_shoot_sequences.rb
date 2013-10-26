class CreateDeviceShootSequences < ActiveRecord::Migration
  def change
    create_table :device_shoot_sequences do |t|
      t.references :shoot_sequence, :null => false
      t.references :device_area, :null => false
      t.integer :order_num, :null => false
      t.references :device, :null => false

      t.timestamps
    end

    add_index :device_shoot_sequences, :shoot_sequence_id
    add_index :device_shoot_sequences, :device_area_id
    add_index :device_shoot_sequences, :device_id
    add_index :device_shoot_sequences, [ :shoot_sequence_id, :device_area_id, :order_num ], :name => "unique_index", :unique => true
  end
end
