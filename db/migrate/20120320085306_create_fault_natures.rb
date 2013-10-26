class CreateFaultNatures < ActiveRecord::Migration
  def change
    create_table :fault_natures do |t|
      t.string :name, :null => false
      t.string :notes

      t.timestamps
    end

    add_index :fault_natures, :name, :unique => true
  end
end
