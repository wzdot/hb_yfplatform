class CreatePartPositionShootSequences < ActiveRecord::Migration
  def change
    create_table :part_position_shoot_sequences do |t|
      t.references :shoot_sequence, :null => false
      t.references :device_area, :null => false
      t.references :device, :null => false
      t.integer :order_num, :null => false
      t.references :part_position, :null => false

      t.timestamps
    end

    add_index :part_position_shoot_sequences, :shoot_sequence_id
    add_index :part_position_shoot_sequences, :device_area_id
    add_index :part_position_shoot_sequences, :device_id
    add_index :part_position_shoot_sequences, :part_position_id
    add_index :part_position_shoot_sequences, [ :shoot_sequence_id, :device_area_id, :device_id, :order_num ], :name => "unique_index", :unique => true
  end
end
