class CreateVoltageLevels < ActiveRecord::Migration
  def change
    create_table :voltage_levels do |t|
      t.string :name, :null => false
      t.string :notes

      t.timestamps
    end

    add_index :voltage_levels, :name, :unique => true
  end
end
