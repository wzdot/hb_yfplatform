class CreateFixMethods < ActiveRecord::Migration
  def change
    create_table :fix_methods do |t|
      t.string :name, :null => false
      t.string :notes

      t.timestamps
    end

    add_index :fix_methods, :name, :unique => true
  end
end
