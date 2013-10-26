class CreateFaultDegrees < ActiveRecord::Migration
  def change
    create_table :fault_degrees do |t|
      t.string :name, :null => false
      t.string :notes

      t.timestamps
    end

    add_index :fault_degrees, :name, :unique => true
  end
end
