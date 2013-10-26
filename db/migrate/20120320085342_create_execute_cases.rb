class CreateExecuteCases < ActiveRecord::Migration
  def change
    create_table :execute_cases do |t|
      t.string :name, :null => false
      t.string :notes

      t.timestamps
    end

    add_index :execute_cases, :name, :unique => true
  end
end
