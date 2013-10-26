class CreatePartPositions < ActiveRecord::Migration
  def change
    create_table :part_positions do |t|
      t.string :name, :null => false
      t.string :notes

      t.timestamps
    end

    add_index :part_positions, :name, :unique => true
  end
end
